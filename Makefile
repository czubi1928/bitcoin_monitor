up:
	docker compose up --build -d

terraform_apply:
	docker compose run --rm terraform apply