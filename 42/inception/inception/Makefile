all: build up

down:
	@echo "Stopping and removing containers, networks, volumes, and images..."
	docker compose -f srcs/docker-compose.yml down

build:
	@echo "Building Docker images without cache..."
	docker compose -f srcs/docker-compose.yml build --no-cache

up: build
	@echo "Starting containers in detached mode..."
	docker compose -f srcs/docker-compose.yml up

clean: kill
	@echo "Pruning Docker system to remove all unused data..."
	docker system prune -a --volumes -f

st:
	@echo "Listing Docker images and running containers..."
	docker images
	docker ps

kill:
	@echo "Killing all running containers..."
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

re: down kill clean all

.PHONY: all down clean re st
