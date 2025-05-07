#!/bin/bash

export GH_TOKEN="" # read:packages & write:packages

REPO_OWNER=romanratushnyi
REPO_NAME=test-docker-ghcr
IMAGE_NAME=ghcr.io/$REPO_OWNER/$REPO_NAME
CONTAINER_NAME=synchronize-exact-app

echo $GH_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

CURRENT_VERSION=""
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Trying to get version from container $CONTAINER_NAME..."
  CURRENT_VERSION=$(docker exec "$CONTAINER_NAME" node -p "'v' + require('./package.json').version" 2>/dev/null || true)
else
  echo "Container $CONTAINER_NAME not found."
fi
echo "Current version: ${CURRENT_VERSION:-<unknown>}"

LATEST_VERSION=$(gh api "users/$REPO_OWNER/packages/container/$REPO_NAME/versions" --paginate | jq -r '.[].metadata.container.tags[]' | grep '^v' | sort -V | tail -n1)
echo "Latest version in GHCR: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating to $LATEST_VERSION..."
  
  docker compose pull

  docker tag "$IMAGE_NAME:$LATEST_VERSION" "$IMAGE_NAME:latest"

  OLD_IMAGE_ID=$(docker images --filter "reference=$IMAGE_NAME" --filter "before=$IMAGE_NAME:$LATEST_VERSION" -q)
  
  docker compose down
  
  docker compose up -d

  if [ -n "$OLD_IMAGE_ID" ]; then
    echo "Removing old image $OLD_IMAGE_ID..."
    docker rmi -f "$OLD_IMAGE_ID"
  else
    echo "No old image to remove."
  fi
else
  echo "No update needed."
fi
