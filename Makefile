# --- Variables ---
DOCKER_COMPOSE = docker compose

TF_RUN  = $(DOCKER_COMPOSE) run --rm terraform

DBT = $(DOCKER_COMPOSE) run --rm dbt
DBT_SERVE = $(DOCKER_COMPOSE) run --service-ports dbt


# --- Python Environment Management ---
.PHONY: pip_install_dependencies
pip_install_dependencies:
	pip install .

.PHONY: pre_commit_install
pre_commit_install:
	pre-commit install


# --- Docker Management ---
.PHONY: docker_compose_up
docker_compose_up:
	$(DOCKER_COMPOSE) up --build -d

.PHONY: docker_compose_down
docker_compose_down:
	$(DOCKER_COMPOSE) down

.PHONY: docker_compose_restart
docker_compose_restart: docker_compose_down docker_compose_up


# --- Infrastructure (Terraform) ---
.PHONY: terraform_init
terraform_init:
	$(TF_RUN) init

.PHONY: terraform_plan
terraform_plan:
	$(TF_RUN) plan

.PHONY: terraform_apply
terraform_apply:
	$(TF_RUN) apply # -auto-approve

.PHONY: terraform_destroy
terraform_destroy:
	$(TF_RUN) destroy


# --- Transformation (dbt) ---
.PHONY: dbt_elementary_init
dbt_elementary_init:
	$(DBT) run --select elementary

.PHONY: dbt_deps
dbt_deps:
	$(DBT) deps

.PHONY: dbt_debug
dbt_debug:
	$(DBT) debug

.PHONY: dbt_build
dbt_build:
	$(DBT) build

.PHONY: dbt_snapshot
dbt_snapshot:
	$(DBT) snapshot

.PHONY: dbt_run
dbt_run:
	$(DBT) run

.PHONY: dbt_docs_generate
dbt_docs_generate:
	$(DBT) docs generate

.PHONY: dbt_docs_serve
dbt_docs_serve:
	$(DBT_SERVE) docs serve --port 8001 --host 0.0.0.0


# --- Observability ---
.PHONY: observe_freshness
observe_freshness:
	$(DBT) source freshness

.PHONY: observe_test
observe_test:
	$(DBT) test --select tag:observability

.PHONY: observe_all
observe_all: observe_freshness observe_test


# --- CI/CD ---
.PHONY: sql_fluff_lint
sql_fluff_lint:
	docker compose run --rm --entrypoint /bin/bash dbt -c "sqlfluff lint"

.PHONY: sql_fluff_fix
sql_fluff_fix:
	docker compose run --rm --entrypoint /bin/bash dbt -c "sqlfluff fix"


# --- Expert "Onboarding" Command ---
# Use this to set up the whole project from zero to hero in one go.
#.PHONY: setup
setup: pip_install_dependencies terraform_init terraform_apply docker_compose_up dbt_deps dbt_build dbt_docs_generate dbt_docs_serve
	@echo "✅ Project is fully deployed and data is flowing!"