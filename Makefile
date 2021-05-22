# Include variables from the .envrc file
include .envrc

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'
## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN}
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

#==============================#
# BUILD
#==============================#

current_time = $(shell date --iso-8601=seconds)
git_tag_version = $(shell git describe --tags --long --dirty --always)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_tag_version}'

## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	go build -ldflags=${linker_flags} -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api
