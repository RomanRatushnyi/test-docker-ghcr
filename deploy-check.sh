#!/bin/bash
REPO_OWNER=romanratushnyi
REPO_NAME=test-docker-ghcr
IMAGE_NAME=ghcr.io/$REPO_OWNER/$REPO_NAME/synchronize-exact-app
CONTAINER_NAME=synchronize-exact-app

CURRENT_VERSION=$(docker inspect --format '{{ index .Config.Image }}' "$CONTAINER_NAME" 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')
echo "Current version: $CURRENT_VERSION"

LATEST_VERSION=$(gh api "users/$REPO_OWNER/packages/container/$REPO_NAME/versions" --paginate | jq -r '.[].metadata.container.tags[]' | grep '^v' | sort -V | tail -n1)
echo "Latest version in GHCR: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating to $LATEST_VERSION..."
  
  docker pull $IMAGE_NAME:$LATEST_VERSION
  
  docker rm -f $CONTAINER_NAME || true
  
  docker run -d --name $CONTAINER_NAME -p 8080:80 $IMAGE_NAME:$LATEST_VERSION
else
  echo "No update needed."
fi
