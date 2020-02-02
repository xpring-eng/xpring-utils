# build.sh 

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Acknowledgements](#acknowledgements) 

## Overview <a name="overview"></a>
This script automates the build process for a Xpring app. Specifically, it:
- Creates a release draft for the app, which:
  - Bumps the app version (major, minor, or patch)
  - Includes all commits, authors, and date of commits in the release 
- Updates the app version in the dockerfile and makes a pull request
- Creates a draft release for the dockerfile for the app
- Updates the dockerfile version in the salt file(s) and makes a pull request

## Installation <a name="installation"></a>
This uses Github's cli tool, `hub`. To install using homebrew:

`brew install hub`

For other installation options, refer to the [hub README](https://github.com/github/hub). On the first run, you will need to
authenticate hub with your github credentials.

You will also need read/write permissions to all the relevant app, dockerfile, and salt repos.

## Usage <a name="usage"></a>
From within the `build` directory, run:

`./build.sh <app-environment> <version>`

More specifically:

`<app-environment>` - the env file for the app you want to build
`<version>` - the magnitude of version bump: `major`, `minor`, or `patch`

## Examples <a name="examples"></a>
We can run through an example with [xpring-wallet-system](https://github.com/xpring-eng/xpring-wallet-system).

__NOTE: This creates release DRAFTS and PRs across three repositories. Make sure to delete these if you do not intend
to actually use them.__

There are 4 main steps to build (and deploy):
1. Configure Environment
2. Run Build Script 
3. Approve Releases and Merge PRs 
4. Deploy with Chatops

### Configure Environment 
First, we need to properly set the build environment. For the wallet, this is in `wallet.env`:

__App Environment__
* `APP_REPO=xpring-eng/xpring-wallet-system` - the app repo 
* `COMMIT_START=#279` - the commit number to start the release from
* `APP_RELEASE_TITLE="Release $APP_VERSION - Since $COMMIT_START"` - the release title

__Docker Environment__
* `DOCKER_REPO=xpring-eng/xpring-wallet-system-docker` - the docker repo for the app
* `DOCKER_RELEASE_TITLE="Release $DOCKER_VERSION"` - the release title

__Salt Environment__
* `SALT_REPO=xpring-eng/xpring-salt` - the salt repo for the app/dockerfile 
* `SALT_APP=walletsystem` - the name of the app (specifically, as named in the salt files)

### Run Build Script 
We can now run this with a `patch` bump as follows:

`./build.sh wallet.env patch`

If this is the first time, you may get a permissions prompt for `hub`.

### Approve Releases and Merge PRs
After the script finishes, there should be:
- A release draft on: https://github.com/xpring-eng/xpring-wallet-system/releases
- A PR on: https://github.com/xpring-eng/xpring-wallet-system-docker/pulls
- A release draft on: https://github.com/xpring-eng/xpring-wallet-system-docker/releases
- A PR on: https://github.com/xpring-eng/xpring-salt/pulls


### Deploy with Chatops
Follow 

## Acknowledgements <a name="acknowledgements"></a>
Thank you to:
[John Albietz](https://github.com/inthecloud247) for making the build and deploy pipeline!
[Elliot Lee](https://github.com/intelliot) for outlining the build and deploy flow in a document! 
[Francois Saint-Jacques](https://github.com/fsaintjacques) for an easy-to-use versioning script! 
