help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  docker-create                Create containers, then start containers and create database"
	@echo "  docker-delete                Destroy containers and database"
	@echo ""
	@echo "  docker-start                 Start containers"
	@echo "  docker-stop                  Stop containers"
	@echo ""
	@echo "  artisan-fresh                Recreate database"
	@echo "  artisan-migrate              Migrate database to last release"
	@echo ""
	@echo "  psql-dump                    Dump database"
	@echo "  psql-restore                 Restore database dump"
	@echo ""
	@echo "  enter-nginx-container        Enter nginx container"
	@echo "  enter-php-container          Enter php container"
	@echo "  enter-psql-container         Enter psql container"
	@echo ""

docker-create:
	@mkdir -p ./data/postgresql-data
	@mkdir -p ./data/dumps
	@docker compose build
	@docker compose up -d --wait
	@docker compose exec nginx /bin/sh -c "chmod -R 777 /var/www/html/storage"
	@cp ./src/.env.example ./src/.env
	@docker compose exec php /bin/sh -c "composer install"
	@docker compose exec php /bin/sh -c "php artisan key:generate"
	@docker compose exec php /bin/sh -c "php artisan migrate"

docker-delete:
	@docker compose down
	@rm -rf ./data

docker-start:
	@docker compose up -d

docker-stop:
	@docker compose down

artisan-fresh:
	@docker compose exec php /bin/sh -c "php artisan migrate:fresh"

artisan-migrate:
	@docker compose exec php /bin/sh -c "php artisan migrate"

psql-dump:
	@docker compose exec -t psql pg_dumpall -c -U postgres > data/dumps/db.sql

psql-restore:
	@cat data/dumps/db.sql | docker compose exec -T psql psql -U postgres

enter-nginx-container:
	@docker compose exec -it nginx /bin/sh

enter-php-container:
	@docker compose exec -it php /bin/sh

enter-psql-container:
	@docker compose exec -it psql /bin/sh
