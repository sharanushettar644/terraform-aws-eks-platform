# Usage: make plan ENV=dev | make apply ENV=prod | make destroy ENV=dev
ENV ?= dev
DIR := environments/$(ENV)

.PHONY: bootstrap init fmt validate lint security plan apply destroy kubeconfig

bootstrap:
	cd bootstrap && terraform init && terraform apply

init:
	cd $(DIR) && terraform init

fmt:
	terraform fmt -recursive

validate: init
	cd $(DIR) && terraform validate

lint:
	tflint --init && tflint --recursive

security:
	trivy config --severity HIGH,CRITICAL --ignorefile .trivyignore .

plan: init
	cd $(DIR) && terraform plan -out=tfplan

apply:
	cd $(DIR) && terraform apply tfplan

destroy:
	cd $(DIR) && terraform destroy

kubeconfig:
	$$(cd $(DIR) && terraform output -raw configure_kubectl)
