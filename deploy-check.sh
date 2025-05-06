#!/bin/bash

export GH_TOKEN="" # read:packages & write:packages
git pull

REPO_OWNER=romanratushnyi
REPO_NAME=test-docker-ghcr
IMAGE_NAME=ghcr.io/$REPO_OWNER/$REPO_NAME
CONTAINER_NAME=synchronize-exact-app

echo $GH_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

# Get version from container if Node.js is available
# CURRENT_VERSION=$(docker exec "$CONTAINER_NAME" node -p "'v' + require('./package.json').version")
CURRENT_VERSION="v$(jq -r .version package.json)"
echo "Current version: $CURRENT_VERSION"

LATEST_VERSION=$(gh api "users/$REPO_OWNER/packages/container/$REPO_NAME/versions" --paginate | jq -r '.[].metadata.container.tags[]' | grep '^v' | sort -V | tail -n1)
echo "Latest version in GHCR: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating to $LATEST_VERSION..."
  
  docker compose pull
  
  docker compose down
  
  docker compose up -d
else
  echo "No update needed."
fi
