export TF_VAR_project_name	 = tarhche
export TF_VAR_instance_name	 = backend

export EC2_SSH_ADDRESS		 = ec2-3-124-72-48.eu-central-1.compute.amazonaws.com
export EC2_SSH_USER 		 = ubuntu
export EC2_SSH_ENDPOINT 	 = ${EC2_SSH_USER}@${EC2_SSH_ADDRESS}
export VOLUME_PATH           = ./tmp/volume_01

export MONGO_USERNAME = test
export MONGO_PASSWORD = test‍

export DASHBOARD_MONGO_USERNAME    = username
export DASHBOARD_MONGO_PASSWORD    = password

export PROXY_IMAGE = ghcr.io/tarhche/proxy:latest
export AWS_PROFILE = mahdi

# username: admin
# password: admin-password (in bcrypt, a dollar-sign should be escaped by an arbitrary dollar-sign ($ --> $$))
export PORTAINER_ADMIN_PASSWORD = $$2a$$12$$4xcOa82Ni5rjgQF.v.JWi.i71OyUm3fwmfWiumgJHIAPGU.uOw3qu

validate:
	terraform -chdir=aws validate

fmt:
	terraform -chdir=aws fmt

init:
	terraform -chdir=aws init

state:
	terraform -chdir=aws state list

plan:
	terraform -chdir=aws plan

apply:
	terraform -chdir=aws apply
	rm -f aws/terraform.tfstate aws/terraform.tfstate.*

refresh:
	terraform -chdir=aws refresh

public_key:
	ssh-keygen -y -f ssh-private-key.pem > ssh-public-key.pub

ssh:
	ssh -i "ssh-private-key.pem" ${EC2_SSH_ENDPOINT}

up:
	docker compose -f compose.mongodb.yaml --project-name mongodb up --pull always --detach
	docker compose -f compose.mongodb_dashboard.yaml --project-name mongodb_dashboard up --pull always --detach
	docker compose -f compose.nats.yaml --project-name nats up --pull always --detach
	docker compose -f compose.docker.yaml --project-name docker up --pull always --detach
	docker compose -f compose.docker_dashboard.yaml --project-name docker_dashboard up --pull always --detach
	docker compose -f compose.proxy.yaml --project-name proxy up --pull always --detach --build

down:
	docker compose -f compose.proxy.yaml --project-name proxy down --volumes --remove-orphans
	docker compose -f compose.nats.yaml --project-name nats down --volumes --remove-orphans
	docker compose -f compose.docker_dashboard.yaml --project-name docker_dashboard down --volumes --remove-orphans
	docker compose -f compose.docker.yaml --project-name docker down --volumes --remove-orphans
	docker compose -f compose.mongodb_dashboard.yaml --project-name mongodb_dashboard down --volumes --remove-orphans
	docker compose -f compose.mongodb.yaml --project-name mongodb down --volumes --remove-orphans
