#! /usr/bin/env bash
#
# via ChatGPT: shows docker resources sorted by size
#
## OLD: #!/usr/bin/env bash
#
# docker-resource-sizes.bash: Show practical Docker disk-space reports, with
# largest resources first. Supports Docker Engine on Linux and Docker Desktop
# on macOS.
#
# Note:
# - See bash-cheatsheet.md for commonly used bash snippets.
# - Reworked with template.bash option parsing and selective reporting via
#   Antigravity (Gemini 4 Argon Medium).
#

# Set bash regular and/or verbose tracing
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi
## OLD: set -euo pipefail
if [[ "${STRICT:-1}" == "1" ]]; then
    set -euo pipefail
fi

# Display command-line usage
function usage() {
    local script
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [--all] [--images] [--containers] [--cache] [--df] [--volumes] [--tips] [--verbose] [--trace] [--help] [-- | -]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$script --"
    echo ""
    echo "$script --df"
    echo ""
    echo "$script --tips"
    echo ""
    echo "$script --all --tips"
    echo ""
    echo "Notes:"
    echo "- By default (with -- or --all), shows all size reports without cleanup tips."
    echo "- Use --tips (or -c) to display Docker disk-space cleanup commands."
    echo "- Section options (-i/--images, -C/--containers, -b/--cache, -d/--df, -V/--volumes, -c/--tips) can be combined."
    echo "- The -- option uses defaults and avoids the usage statement."
    echo "- Use DEBUG_SCRIPT=1 to show getopt processing."
    echo ""
}

# Initialize options
show_usage=0
trace=0
verbose=0
show_all=0
show_images=0
show_containers=0
show_cache=0
show_df=0
show_volumes=0
show_tips=0
DEBUG_SCRIPT=$([ "${DEBUG_SCRIPT:-0}" -eq 1 ] && echo true || echo false)
orig_argc=$#

# Parse options with getopt
# Note:
# - getopt unravels combined short options (e.g., "-tv" -> "-t -v")
# - see examples/chatgpt-get-long-options-parsing.bash for more background.
status=0
TEMP=$(getopt -o abcCdhitvV --long all,build-cache,cache,cleanup-tips,containers,df,disk-free,help,images,tips,trace,verbose,volumes -n "$0" -- "$@") || status=$?
if [ $status != 0 ]; then
    echo "Error: getopt failed (status=$status); terminating." >&2
    exit 1
fi
$DEBUG_SCRIPT && echo "TEMP=$TEMP"
# Reassign $1, $2, etc. to the normalized getopt output.
# Note: quotes around "$TEMP" are essential.
eval set -- "$TEMP"

# Process each option
while true; do
    $DEBUG_SCRIPT && echo "\$1=$1"
    case "$1" in
        -a|--all)
            show_all=1
            shift
            ;;
        -b|--cache|--build-cache)
            show_cache=1
            shift
            ;;
        -c|--tips|--cleanup-tips)
            show_tips=1
            shift
            ;;
        -C|--containers)
            show_containers=1
            shift
            ;;
        -d|--df|--disk-free)
            show_df=1
            shift
            ;;
        -h|--help)
            show_usage=1
            shift
            ;;
        -i|--images)
            show_images=1
            shift
            ;;
        -t|--trace)
            trace=1
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        -V|--volumes)
            show_volumes=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: unexpected option: $1" >&2
            exit 1
            ;;
    esac
done

# Support trailing "-" as synonym for "--"
if [ "$#" -eq 1 ] && [ "$1" == "-" ]; then
    shift
fi

# Apply trace and verbose now that they've been parsed
# note: This is the preferred way to trace the script proper
if [ "$trace" == "1" ]; then
    set -o xtrace
fi
if [ "$verbose" == "1" ]; then
    set -o verbose
fi

# Show usage if --help or if no arguments were given at all (orig_argc=0).
# Note: passing -- explicitly skips the no-arg check (orig_argc > 0).
if [ "$show_usage" == "1" ] || [ "$orig_argc" -eq 0 ]; then
    usage
    exit
fi

# Enable all size sections when --all is given or when no specific section was selected
if [ "$show_all" == "1" ] || { [ "$show_images" == "0" ] && [ "$show_containers" == "0" ] && [ "$show_cache" == "0" ] && [ "$show_df" == "0" ] && [ "$show_volumes" == "0" ] && [ "$show_tips" == "0" ]; }; then
    show_images=1
    show_containers=1
    show_cache=1
    show_df=1
    show_volumes=1
fi


###############################################################################
# 0. Require Docker CLI and a reachable Docker daemon.
#
# On macOS, first try the normal Docker configuration.  If it fails, try the
# Docker Desktop per-user socket:
#
#   ~/.docker/run/docker.sock
#
# This accommodates a stale DOCKER_HOST=unix:///var/run/docker.sock setting.
###############################################################################

if [ "$show_images" == "1" ] || [ "$show_containers" == "1" ] || [ "$show_cache" == "1" ] || [ "$show_df" == "1" ] || [ "$show_volumes" == "1" ]; then
    if ! command -v docker >/dev/null 2>&1; then
        printf '%s\n' 'ERROR: docker is not installed or is not in PATH.' >&2
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        case "$(uname -s)" in
            Darwin)
                docker_desktop_socket="${HOME}/.docker/run/docker.sock"

                if [[ -S "${docker_desktop_socket}" ]]; then
                    export DOCKER_HOST="unix://${docker_desktop_socket}"

                    printf '%s\n' \
                        'WARNING: The configured Docker endpoint did not work.' \
                        "WARNING: Using Docker Desktop socket: ${DOCKER_HOST}" \
                        >&2
                fi
                ;;
        esac
    fi

    if ! docker info >/dev/null 2>&1; then
        printf '%s\n' \
            'ERROR: Cannot connect to a Docker daemon.' \
            '' \
            'Current Docker endpoint:' \
            "  ${DOCKER_HOST:-set by the active Docker context}" \
            >&2
        exit 1
    fi
fi


###############################################################################
# 1. Images — largest unique image IDs first.
#
# An image may have multiple tags.  Group tags by image ID so one image is not
# reported repeatedly merely because it has multiple names.
#
# Image-size values include shared layers.  Do not add the displayed values and
# expect the result to equal Docker's actual image storage consumption.
###############################################################################

if [ "$show_images" == "1" ]; then
    printf '\n=== Largest unique Docker images ===\n'

    docker image ls --all --no-trunc \
        --format '{{.ID}}\t{{.Size}}\t{{.Repository}}:{{.Tag}}' \
        | awk -F '\t' '
            {
                image_id = $1
                image_size[image_id] = $2

                if (image_tags[image_id] == "") {
                    image_tags[image_id] = $3
                } else {
                    image_tags[image_id] = image_tags[image_id] ", " $3
                }
            }

            END {
                for (image_id in image_size) {
                    printf "%s\t%s\t%s\n", \
                        image_size[image_id], \
                        image_tags[image_id], \
                        image_id
                }
            }
        ' \
        | sort -h -r
fi


###############################################################################
# 2. Containers — largest writable layers first.
#
# The first SIZE value is the writable container layer.
# The "virtual" value additionally includes its image layers.
###############################################################################

if [ "$show_containers" == "1" ]; then
    printf '\n=== Largest Docker containers (writable layer first) ===\n'

    docker ps --all --size \
        --format '{{.Size}}\t{{.Names}}\t{{.Image}}\t{{.ID}}' \
        | sort -h -r
fi


###############################################################################
# 3. BuildKit build cache.
#
# Docker provides size and reclaimability information, but no general
# machine-readable size-sorted cache listing.
###############################################################################

if [ "$show_cache" == "1" ]; then
    printf '\n=== Docker BuildKit build cache ===\n'

    docker builder du --verbose
fi


###############################################################################
# 4. Docker storage accounting.
#
# This is Docker's own authoritative accounting for images, containers, local
# volumes, and build cache.  It also reports reclaimable space.
###############################################################################

if [ "$show_df" == "1" ]; then
    printf '\n=== Docker detailed disk-space report ===\n'

    docker system df --verbose
fi


###############################################################################
# 5. Linux only — actual named-volume data-directory sizes.
#
# Docker Desktop on macOS keeps these directories inside its Linux VM, not as
# directly accessible ordinary directories on the macOS host.
###############################################################################

if [ "$show_volumes" == "1" ]; then
    case "$(uname -s)" in
        Linux)
            ## BAD: unprivileged shell glob fails when /var/lib/docker/volumes is only root-readable
            ## docker_root="$(docker info --format '{{.DockerRootDir}}')"
            ##
            ## printf '\n=== Largest Docker named-volume data directories ===\n'
            ##
            ## shopt -s nullglob
            ## volume_data_dirs=( "${docker_root}"/volumes/*/_data )
            ## shopt -u nullglob
            printf '\n=== Largest Docker named-volume data directories ===\n'

            # Query volume mountpoints via Docker daemon so path discovery works prior to sudo du
            mapfile -t volume_data_dirs < <(
                docker volume ls -q | xargs -r docker volume inspect --format '{{.Mountpoint}}'
            )

            if ((${#volume_data_dirs[@]} == 0)); then
                printf '%s\n' 'No named-volume data directories found.'
            else
                sudo du -s -h "${volume_data_dirs[@]}" \
                    | sort -h -r
            fi
            ;;

        Darwin)
            printf '%s\n' \
                '' \
                '=== Docker named-volume directory sizes ===' \
                'Skipped on macOS: Docker Desktop stores volume data inside its Linux VM.' \
                'See "docker system df --verbose" above for Docker volume accounting.'
            ;;
    esac
fi


###############################################################################
# 6. Cleanup tips.
#
# Show commands for reclaiming Docker disk space without executing them,
# given the potential for data loss (especially with named volumes).
# Only shown in full when --tips (-c) is specified so size output is not
# obscured.
# note: added via Antigravity (Gemini 4 Argon Medium)
###############################################################################

if [ "$show_tips" == "1" ]; then
    cat <<'EOF'

=== Docker cleanup tips (not run automatically to avoid data loss) ===
* Standard prune (stopped containers, unused networks, dangling images/cache):
    docker system prune
* Prune all unused images and build cache (plus anonymous volumes):
    docker system prune -a --volumes
* Prune all unused volumes, INCLUDING named volumes (Docker 23.0+ skips named volumes unless -a is given):
    docker volume prune -a
* Selectively remove specific volumes by prefix (e.g., codeprefs- or act-):
    docker volume ls -q | grep -E '^(codeprefs-|act-)' | xargs -r docker volume rm
* Find containers and host PIDs referencing a specific volume (when "volume is in use"):
    docker ps -a --filter volume=<volume_name>
    docker ps -q --filter volume=<volume_name> | xargs -r docker inspect --format '{{.Id}} ({{.Name}}): Status={{.State.Status}} PID={{.State.Pid}}'
    sudo lsof +D "$(docker volume inspect --format '{{.Mountpoint}}' <volume_name>)"
* Remove stopped (or running, with -f) containers blocking codeprefs-/act- volumes, then remove the volumes:
    docker ps -aq --filter status=exited --filter status=created --filter "name=^(codeprefs-|act-)" | xargs -r docker rm -v
    docker volume ls -q | grep -E '^(codeprefs-|act-)' | xargs -r docker volume rm
* Full container/image reset via shell alias (note: does not remove named volumes):
    docker-cleanup
EOF
else
    printf '\n# Tip: run "%s --tips" for Docker space cleanup commands.\n' "$(basename "$0")"
fi

