#! /usr/bin/env bash
#
# via ChatGPT: shows docker resources sorted by size

#!/usr/bin/env bash
#
# docker-resource-sizes.bash
#
# Show practical Docker disk-space reports, with largest resources first.
# Supports Docker Engine on Linux and Docker Desktop on macOS.
#

set -euo pipefail


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


###############################################################################
# 1. Images — largest unique image IDs first.
#
# An image may have multiple tags.  Group tags by image ID so one image is not
# reported repeatedly merely because it has multiple names.
#
# Image-size values include shared layers.  Do not add the displayed values and
# expect the result to equal Docker's actual image storage consumption.
###############################################################################

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


###############################################################################
# 2. Containers — largest writable layers first.
#
# The first SIZE value is the writable container layer.
# The "virtual" value additionally includes its image layers.
###############################################################################

printf '\n=== Largest Docker containers (writable layer first) ===\n'

docker ps --all --size \
    --format '{{.Size}}\t{{.Names}}\t{{.Image}}\t{{.ID}}' \
    | sort -h -r


###############################################################################
# 3. BuildKit build cache.
#
# Docker provides size and reclaimability information, but no general
# machine-readable size-sorted cache listing.
###############################################################################

printf '\n=== Docker BuildKit build cache ===\n'

docker builder du --verbose


###############################################################################
# 4. Docker storage accounting.
#
# This is Docker's own authoritative accounting for images, containers, local
# volumes, and build cache.  It also reports reclaimable space.
###############################################################################

printf '\n=== Docker detailed disk-space report ===\n'

docker system df --verbose


###############################################################################
# 5. Linux only — actual named-volume data-directory sizes.
#
# Docker Desktop on macOS keeps these directories inside its Linux VM, not as
# directly accessible ordinary directories on the macOS host.
###############################################################################

case "$(uname -s)" in
    Linux)
        docker_root="$(docker info --format '{{.DockerRootDir}}')"

        printf '\n=== Largest Docker named-volume data directories ===\n'

        shopt -s nullglob
        volume_data_dirs=( "${docker_root}"/volumes/*/_data )
        shopt -u nullglob

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
