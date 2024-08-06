NAME = inception

all: $(NAME)

$(NAME):
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down

clean: down
	@docker system prune -a

fclean: clean
	@docker volume rm $$(docker volume ls -q)

re: fclean all

.PHONY: all down clean fclean re

/*
all:
	@docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	@docker compose -f ./srcs/docker-compose.yml down

re:
	@docker compose -f ./srcs/docker-compose.yml up -d --build

clean:
	@docker stop $$(docker ps -qa);\
	docker rm $$(docker ps -qa);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm srcs_inception

.PHONY: all re down clean
*/