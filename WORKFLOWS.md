## Information on the workflows files

Two Workflow files (act and python)

A Dockerfile
A script called local-workflows.sh

One of the files is tentatively still named python and responds to the tests as such for use by Github, both Python and Bash.

The rest are part of the mechanism for local testing. It works quite simply, by cloning the repository and running the local-workflows script, it will automatically build a custom Docker image, register the appropriate dependencies and run the tests in the act.yml file locally using `act` .

The act.yml itself is just a test file slightly modified to accept the architecture of a local machine without weird problems.

[Above notes circa May 2023]

## Automated workflows

There are currently two distinct workflows:

* GitHub Actions for testing: [.github/workflows/github.yml](.github/workflows/github.yml)
* Dependabot for dependency updates: [.github/dependabot.yml](.github/dependabot.yml),
  which opens monthly grouped PRs to keep the pinned actions in github.yml current

[Above notes circa September 2026 via Claude Fable 5]
