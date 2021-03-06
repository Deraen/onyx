#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 new-version old-release-branch new-release-branch"
    echo "Example: $0 0.8.0 0.7.x 0.8.x"
else
  # Update to release version.
  git checkout master
  git pull --rebase

  OLD_VERSION=`lein pprint :version|sed s/\"//g`
  NEW_VERSION=$1
  OLD_BRANCH=$2
  NEW_BRANCH=$3

  grep "$OLD_VERSION" README.MD || (echo "Version string $1 was not found in README" && exit 1)

  lein set-version $NEW_VERSION
  sed -i '' "s/$OLD_VERSION/$NEW_VERSION/g" README.md
  sed -i '' "s/$OLD_BRANCH/$NEW_BRANCH/g" README.md
  sed -i '' "s/$OLD_BRANCH/$NEW_BRANCH/g" circle.yml
  git rm -rf doc/api
  lein doc

  # Push and deploy release.
  git add doc
  git commit -m "Release version $NEW_VERSION." project.clj README.md doc
  git tag $NEW_VERSION
  git push origin $NEW_VERSION
  git push origin master

  # Merge artifacts into release branch.
  git checkout $NEW_BRANCH
  git merge --no-edit master
  git push origin $NEW_BRANCH

  # Prepare next release cycle.
  git checkout master
  lein set-version

  SNAPSHOT_VERSION=`lein pprint :version|sed s/\"//g`
  sed -i '' "s/$NEW_VERSION/$SNAPSHOT_VERSION/g" README.md

  git commit -m "Prepare for next release cycle." project.clj README.md
  git push origin master
fi
