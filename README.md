# OpenDevin Docker

Builds and runs a Docker instance of the [OpenDevin](https://github.com/OpenDevin/OpenDevin) project

## Notes

### 04/12/2024
Right now the Dockerfile is cloneing my fork of OpenDevin due to the maker file needed a nondocker build. This means not to start the docker with make build as you can't have a docker inside a docker. The sandbox docker for OpenDevin is pulled in the run script. Will update to use non-forked version if PR gets approved on main.

## Run

### Windows
Use **run_opendevin.ps1**

Windows is currently having networking issues. 3001 doesn't seem to be reachable and looking for a solution.

### Linux/MacOS
Use **run_opendevin.sh**

