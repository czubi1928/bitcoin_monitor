# --- Variables ---
DOCKER_COMPOSE = docker compose
DBT = $(DOCKER_COMPOSE) run --rm dbt
DBT_SERVE = $(DOCKER_COMPOSE) run --service-ports dbt
TF_RUN  = $(DOCKER_COMPOSE) run --rm terraform

# --- Environment Management ---
.PHONY: up
up:
	$(DOCKER_COMPOSE) up --build -d

.PHONY: down
down:
	$(DOCKER_COMPOSE) down

.PHONY: logs
logs:
	$(DOCKER_COMPOSE) logs -f

.PHONY: restart
restart: down up

# --- Infrastructure (Terraform) ---
.PHONY: tf-init
tf-init:
	$(TF_RUN) init

.PHONY: tf-plan
tf-plan:
	$(TF_RUN) plan

.PHONY: tf-apply
tf-apply:
	$(TF_RUN) apply -auto-approve

.PHONY: tf-destroy
tf-destroy:
	$(TF_RUN) destroy

# --- Transformation (dbt) ---
.PHONY: dbt-deps
dbt-deps:
	$(DBT) deps

.PHONY: dbt-debug
dbt-debug:
	$(DBT) debug

.PHONY: dbt-build
dbt-build:
	$(DBT) build

.PHONY: elementary-init
elementary-init:
	$(DBT) run --select elementary

.PHONY: dbt-snapshot
dbt-snapshot:
	$(DBT) snapshot

.PHONY: dbt-run
dbt-run:
	$(DBT) run

.PHONY: dbt-docs
dbt-docs:
	$(DBT) docs generate
	$(DBT_SERVE) docs serve --port 8001 --host 0.0.0.0

# --- Observability (dbt source freshness and tests) ---
.PHONY: observe-freshness
observe-freshness:
	$(DBT) source freshness

.PHONY: observe-tests
observe-tests:
	$(DBT) test --select tag:observability

.PHONY: observe-all
observe-all: observe-freshness observe-tests

# --- Expert "Onboarding" Command ---
# Use this to set up the whole project from zero to hero in one go.
#.PHONY: setup
setup: tf-init tf-apply up dbt-deps dbt-build
	@echo "✅ Project is fully deployed and data is flowing!"