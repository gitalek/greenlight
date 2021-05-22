## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'
.PHONY: migrate/up
migrate/up: confirm
	@echo 'Running up migratinons...'
	@migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up
## migrate/version: print migration version
.PHONY: migrate/version
migrate/version: confirm
	@migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} version
## migrate/new name=$1: create a new database migration
.PHONY: migrate/new
migrate/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}
## psql/attach: connect to the database using psql
.PHONY: psql/attach
psql/attach:
	@docker exec -it greenlight psql -U greenlight -d greenlight
## psql/command cmd=$1: run command in psql and print result
.PHONY: psql/command
psql/command:
	@docker exec greenlight psql -U postgres -d greenlight -c '${cmd}'
.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [Y/n] ' && read ans && [ $${ans:-n} = Y ]
