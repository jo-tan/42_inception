# -f: --file
# -q: --quiet
# -a: --all
# $$: escape $ for shell
# Variables for better maintainability
COMPOSE_FILE = ./srcs/docker-compose.yml
DOCKER = docker compose -f $(COMPOSE_FILE)
DATA_PATH = /home/jo-tan/data


# Default target - creates directories and starts services
all: build
	mkdir -p $(DATA_PATH)mariadb
	mkdir -p $(DATA_PATH)wordpress
	$(DOCKER) up -d

# Build images without starting containers
build:
	$(DOCKER) build

# Stop services
down:
	$(DOCKER) down

# Separate log targets for each service
logs-nginx:
	docker logs nginx

logs-wp:
	docker logs wordpress

logs-db:
	docker logs mariadb

# View all logs (with option to follow)
logs:
	$(DOCKER) logs

# Show running containers
ps:
	$(DOCKER) ps

# Stop and remove containers, networks
clean:
	$(DOCKER) down -v

# Full cleanup (including images and volumes)
fclean: clean
	docker system prune -af --volumes
	rm -rf $(DATA_PATH)/wordpress
	rm -rf $(DATA_PATH)/mariadb

# Rebuild everything
re: fclean all

# Help target
help:
	@echo "Available targets:"
	@echo "  all        : Start services"
	@echo "  build      : Build images"
	@echo "  down       : Stop services"
	@echo "  logs       : View all logs"
	@echo "  logs-nginx : View Nginx logs"
	@echo "  logs-wp    : View WordPress logs"
	@echo "  logs-db    : View MariaDB logs"
	@echo "  ps         : Show containers"
	@echo "  clean      : Remove containers"
	@echo "  fclean     : Full cleanup"
	@echo "  re         : Rebuild all"

.PHONY: all build down logs logs-nginx logs-wp logs-db ps clean fclean re help