#!/bin/bash

mkdir -p ./logs

# Log file location
LOG_FILE="./logs/scaling_log.txt"

# Redirect stdout and stderr to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

SERVICE_NAME="newcloud"
THRESHOLD_MEMORY=128 # in MiB
CURRENT_MEMORY_LIMIT=256 # in MB
MAX_MEMORY_LIMIT=512 # in MB
DOCKER_COMPOSE_FILE="docker compose.yml"

# Get the current memory usage of the service
CURRENT_MEMORY_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" $SERVICE_NAME | awk '{print $1}' | sed 's/Mi//')

# If the memory usage exceeds the threshold, scale up
echo "Current Memory Usage: $CURRENT_MEMORY_USAGE Mi"

if (( $(echo "$CURRENT_MEMORY_USAGE > $THRESHOLD_MEMORY" | bc -l) )); then
  echo "Memory usage exceeded $THRESHOLD_MEMORY Mi. Scaling out..."

  # Horizontal Scaling
  CURRENT_REPLICAS=$(docker compose -f $DOCKER_COMPOSE_FILE ps | grep $SERVICE_NAME | wc -l)
  NEW_REPLICAS=$((CURRENT_REPLICAS + 1))

  # Scale the service horizontally
  docker compose -f $DOCKER_COMPOSE_FILE up --scale $SERVICE_NAME=$NEW_REPLICAS -d
  echo "Increased replicas to $NEW_REPLICAS."

  # Vertical Scaling Logic
  if (( $(echo "$CURRENT_MEMORY_USAGE > $CURRENT_MEMORY_LIMIT" | bc -l) )); then
    echo "Memory usage exceeded current limit. Checking for vertical scaling..."

    if [ "$CURRENT_MEMORY_LIMIT" -lt "$MAX_MEMORY_LIMIT" ]; then
      NEW_MEMORY_LIMIT=$((CURRENT_MEMORY_LIMIT + 256)) # Increase by 256 MB
      echo "Updating memory limit to $NEW_MEMORY_LIMIT MB in the Docker Compose file..."

      # Check if the mem_limit line exists before trying to replace it
      if grep -q "mem_limit:" $DOCKER_COMPOSE_FILE; then
        # Update the Docker Compose file with the new memory limit
        sed -i "s/mem_limit: ${CURRENT_MEMORY_LIMIT}m/mem_limit: ${NEW_MEMORY_LIMIT}m/" $DOCKER_COMPOSE_FILE
      else
        echo "mem_limit not found in $DOCKER_COMPOSE_FILE."
      fi

      echo "Redeploying service with new memory limit..."
      docker compose -f $DOCKER_COMPOSE_FILE up -d
    else
      echo "Maximum memory limit reached. Cannot scale vertically."
    fi
  fi
else
  echo "Memory usage is within the safe limit."
fi


