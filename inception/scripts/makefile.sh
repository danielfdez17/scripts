#!/bin/bash


# cat << EOF

# all: build up

# down:
# 	@echo "Stopping and removing containers, networks, volumes, and images..."
# 	docker compose -f srcs/docker-compose.yml down

# build:
# 	@echo "Building Docker images without cache..."
# 	docker compose -f srcs/docker-compose.yml build --no-cache

# up: build
# 	@echo "Starting containers in detached mode..."
# 	docker compose -f srcs/docker-compose.yml up

# clean:
# 	@echo "Pruning Docker system to remove all unused data..."
# 	docker system prune -a --volumes -f

# st:
# 	@echo "Listing Docker images and running containers..."
# 	docker images
# 	docker ps

# kill:
# 	@echo "Killing all running containers..."
# 	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

# re: down kill clean all

# .PHONY: all down clean re st

# EOF

echo 'all: build up'
echo ''
echo 'down:'
echo '	@echo "Stopping and removing containers, networks, volumes, and images..."'
echo '	docker compose -f srcs/docker-compose.yml down'
echo ''
echo 'build:'
echo '	@echo "Building Docker images without cache..."'
echo '	docker compose -f srcs/docker-compose.yml build --no-cache'
echo ''
echo 'up: build'
echo '	@echo "Starting containers in detached mode..."'
echo '	docker compose -f srcs/docker-compose.yml up'
echo ''
echo 'clean: kill'
echo '	@echo "Pruning Docker system to remove all unused data..."'
echo '	docker system prune -a --volumes -f'
echo ''
echo 'st:'
echo '	@echo "Listing Docker images and running containers..."'
echo '	docker images'
echo '	docker ps'
echo ''
echo 'kill:'
echo '	@echo "Killing all running containers..."'
echo '	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans'
echo ''
echo 're: down kill clean all'
echo ''
echo '.PHONY: all down clean re st'

# build:
# 	@echo "Building Docker images without cache..."
# 	docker compose -f srcs/docker-compose.yml build --no-cache

# up: build
# 	@echo "Starting containers in detached mode..."
# 	docker compose -f srcs/docker-compose.yml up

# clean:
# 	@echo "Pruning Docker system to remove all unused data..."
# 	docker system prune -a --volumes -f

# st:
# 	@echo "Listing Docker images and running containers..."
# 	docker images
# 	docker ps

# kill:
# 	@echo "Killing all running containers..."
# 	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

# re: down kill clean all

# .PHONY: all down clean re st
