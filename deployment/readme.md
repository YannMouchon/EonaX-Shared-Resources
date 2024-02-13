# Eona-X - Minimum Viable Dataspace

## Prerequisite

- Terraform
- Kind
- cURL or Postman
- Vault CLI

## Create and prepare a local Kubernetes cluster

```bash
kind create cluster -n eonax-cluster --config kind.config.yaml
```

### Install Ingress Controller

We install an Ingress Controller in order to interact with the microservice running in the cluster from the host.

Below command will wait until the ingress controller is ready before returning.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### Configure secret for pulling Eona-X Docker images

You need a token to pull the Docker image of the Eona-X connector. This token is provided by Amadeus.

Once you obtained your token, you'll have _inject_ in the Terraform script. Simply run the following command:

```bash
echo 'docker_image_pull_token = "<YOUR_TOKEN_HERE>"' > terraform.tfvars
```

## Deploy the dataspace

Once you have configured the participants you want to deploy using the `participants` field of
the [variables.tf](variables.tf) file,
simply run the following Terraform command to deploy the dataspace:

```bash
terraform init
terraform apply -auto-approve
```

### Configure the connector(s)

Once the deployment is complete, you can now use the standard APIs of
the [EDC connector](https://app.swaggerhub.com/apis/eclipse-edc-bot/management-api/) to configure
the connectors. For example, to get the federated catalog of a participant called `company1`:

```bash
curl -X POST -d "{\"criteria\":[]}" -H "content-type: application/json" http://localhost/company1/management/federatedcatalog
```

It is also possible to add/remove new secrets within the vault of each participant using the Hashicorp Vault Secret
Engine API.
For example, the following adds a new secret called `foo` with value `bar` within the Vault of the
participant `company1`:

```bash
VAULT_TOKEN=root VAULT_ADDR=http://localhost/company1/vault vault kv put secret/foo content=bar
```


