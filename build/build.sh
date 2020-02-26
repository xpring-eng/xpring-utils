#!/bin/sh

### author: https://github.com/dino-rodriguez

### helpers
# add, commit, push, open PR for repo
function ship() {
  repo=$1
  version=$2

  git add * && \
    git commit -m "version: $version" && \
    git push --set-upstream origin $version

  # open pull request
  hub pull-request --no-edit

  cd .. && rm -rf $repo
}

# draft a release for a repo
function create_release() {
  repo=$1
  increment=$2
  title=$3
  message=$4

  git clone git@github.com:xpring-eng/$repo.git
  cd $repo
  version=v$(git describe --tags | xargs ../semver.sh bump $increment)

  # only get commit history for apps 
  exp="#[0-9]"
  if [[ $message =~ $exp ]]; then
    message=$(git log --pretty=format:"%h%x09%an%x09 | %ai%x09 | %s" | sed "/$message/q")
  fi

  # create release (as draft)
  hub release create -d -m "$title" -m "$message" $version > /dev/null
  cd .. && rm -rf $repo

  echo $version
}

# version bump + submit PR for dockerfile repo 
function update_version_in_dockerfile() {
  # vars
  repo=$1
  app_version=$2
  docker_version=$3

  git clone git@github.com:xpring-eng/$repo.git
  cd $repo
  git checkout -b $docker_version

  # update version in Dockerfile
  sed -i '' -E "s/v[0-9]+\.[0-9]+\.[0-9]+/${app_version}/g" Dockerfile

  ship $repo $docker_version
}

# version bump + submit PR for salt repo 
function update_version_in_salt() {
  # vars
  repo=$1
  version=$2
  app=$3

  git clone git@github.com:xpring-eng/$repo.git
  cd $repo
  git checkout -b $version

  # update version in salt files 
  find . -type f -name "*${app}*" | xargs sed -i '' -E "s/v[0-9]+\.[0-9]+\.[0-9]+/${version}/g"

  ship $repo $version
}

### run
source $1 

# patch, minor, major
increment=$2

# build
app_version=$(create_release $APP_REPO $increment "$APP_RELEASE_TITLE" "$COMMIT_START")
docker_version=$(create_release $DOCKER_REPO $increment "$DOCKER_RELEASE_TITLE" "App Version: $app_version")
update_version_in_dockerfile $DOCKER_REPO $app_version $docker_version
update_version_in_salt $SALT_REPO $docker_version $SALT_APP
