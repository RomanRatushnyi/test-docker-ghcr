export GH_TOKEN="" # read:packages & write:packages

REPO_OWNER=romanratushnyi
REPO_NAME=test-docker-ghcr
IMAGE_NAME=ghcr.io/$REPO_OWNER/$REPO_NAME
CONTAINER_NAME=synchronize-exact-app
CURRENT_VERSION=""

echo "Logging in to GitHub Container Registry..."
echo $GH_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Container $CONTAINER_NAME is not running. Attempting to start it..."
  docker compose up -d

  echo "Waiting for container $CONTAINER_NAME to become ready..."
  for i in {1..20}; do
    if docker exec "$CONTAINER_NAME" true 2>/dev/null; then
      echo "Container $CONTAINER_NAME is ready."
      break
    fi
    echo "Still waiting... ($i/20)"
    sleep 5
  done
  
  if ! docker exec "$CONTAINER_NAME" true 2>/dev/null; then
    echo "Container $CONTAINER_NAME did not become ready."
  fi
else
  echo "Container $CONTAINER_NAME is already running."
fi

CURRENT_VERSION=$(docker exec "$CONTAINER_NAME" sh -c "grep '\"version\"' /app/package.json | head -1 | sed -E 's/.*\"version\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\1/'")
CURRENT_VERSION="v$CURRENT_VERSION"
echo "Current version: ${CURRENT_VERSION:-<unknown>}"

echo "Fetching latest version from GHCR..."
LATEST_VERSION=$(gh api "users/$REPO_OWNER/packages/container/$REPO_NAME/versions" --paginate | jq -r '.[].metadata.container.tags[]' | grep '^v' | sort -V | tail -n1)
echo "Latest version in GHCR: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Updating from $CURRENT_VERSION to $LATEST_VERSION..."

  echo "Pulling latest image..."
  docker compose pull

  echo "Tagging image with version $LATEST_VERSION..."
  docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$LATEST_VERSION"
  
  echo "Stopping current container..."
  docker compose down
  
  echo "Starting updated container..."
  docker compose up -d
  
  echo "Cleaning up dangling images..."
  docker images --filter "dangling=true" -q | xargs -r docker rmi -f
  docker images --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep "<none>:<none>" | awk '{print $1}' | xargs -r docker rmi -f

  echo "Update complete."
else
  echo "No update needed."
fi
