---
title: kubernetes
weight: 100
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## kubernetes plugins

[Dashboard Repository](https://github.com/kubernetes/dashboard)

[Metrics Server Repository](https://github.com/kubernetes-incubator/metrics-server)

[Local Path Provisioner Repository](https://github.com/rancher/local-path-provisioner)

[Proxied Dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

```bash
# Dashboard
kubectl apply --filename https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta3/aio/deploy/recommended.yaml

# Metrics Server
kubectl apply \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/aggregated-metrics-reader.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/auth-delegator.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/auth-reader.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/metrics-apiservice.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/metrics-server-deployment.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/metrics-server-service.yaml \
        --filename https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/v0.3.3/deploy/1.8%2B/resource-reader.yaml
kubectl get apiservice v1beta1.metrics.k8s.io --output json | jq '.status.conditions[]'

# Local Path Provisioner
kubectl apply --filename https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.9/deploy/local-path-storage.yaml

# ServiceAccount Token
kubectl --namespace kube-system get --output json secrets "$(kubectl --namespace kube-system get --output json serviceaccounts default | jq --raw-output '.secrets[0].name')" | jq --raw-output '.data.token' | base64 --decode

# EKS Token
aws eks get-token --cluster-name "my_cluster" | jq --raw-output '.status.token'

# Proxy
kubectl proxy
```

## pods

### how execute docker image in kubernetes

```bash
NAMESPACE="production"
SERVICE="my-app"
kubectl run --rm -it shell --image=alpine --restart=Never -- wget -qO- http://${SERVICE}.${NAMESPACE}.svc.cluster.local
kubectl run --rm -it shell --image=alpine --restart=Never -- wget -qO- https://www.google.com
```

### how to access a kubernetes service/pod

```bash
NAMESPACE="production"
LOCAL_PORT="8080"

SERVICE="my-app"
SERVICE_PORT="80"
kubectl --namespace="${NAMESPACE}" port-forward services/"${SERVICE}" "${LOCAL_PORT}":"${SERVICE_PORT}"

POD="my-app"
POD_PORT="80"
kubectl --namespace="${NAMESPACE}" port-forward pods/"${POD}" "${LOCAL_PORT}":"${POD_PORT}"
```

### show failed pods

```bash
NAMESPACE="production"
kubectl --namespace="${NAMESPACE}" get pods --field-selector=status.phase=Failed
```

### copy from/to pods

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
POD_LABEL=$(kubectl --namespace="${NAMESPACE}" get deployments "${DEPLOYMENT}" --output=jsonpath='{.spec.template.metadata.labels.app}')
POD_NAME=$(kubectl --namespace="${NAMESPACE}" get pods --selector=app="${POD_LABEL}" --output=jsonpath='{.items[0].metadata.name}')

kubectl --namespace="${NAMESPACE}" cp "${POD_NAME}":/etc/letsencrypt etc-letsencrypt
kubectl --namespace="${NAMESPACE}" cp "${POD_NAME}":/etc/nginx/conf.d etc-nginx-conf.d

kubectl --namespace="${NAMESPACE}" cp etc-letsencrypt "${POD_NAME}":/etc/letsencrypt
kubectl --namespace="${NAMESPACE}" cp etc-nginx-conf.d "${POD_NAME}":/etc/nginx/conf.d
```

## deployment

### how to run command in a deployments pod

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
POD_LABEL=$(kubectl --namespace="${NAMESPACE}" get deployments "${DEPLOYMENT}" --output=jsonpath='{.spec.template.metadata.labels.app}')
POD_NAME=$(kubectl --namespace="${NAMESPACE}" get pods --selector=app="${POD_LABEL}" --output=jsonpath='{.items[0].metadata.name}')

kubectl --namespace="${NAMESPACE}" exec -it "${POD_NAME}" -- bash
```

### change deployment image

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
CONTAINER_NAME="my-app"
IMAGE_NAME="nginx"
IMAGE_TAG="1.10"
kubectl --namespace="${NAMESPACE}" set image deployment.apps/"${DEPLOYMENT}" "${CONTAINER_NAME}"="${IMAGE_NAME}:${IMAGE_TAG}"
```

### scale deployment

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" scale deployment --replicas 1 "${DEPLOYMENT}"
```

### watch deployment update

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" rollout status deploy "${DEPLOYMENT}"
```

### deployment history

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" rollout history deploy "${DEPLOYMENT}"
```

### deployment revert

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" rollout undo deploy "${DEPLOYMENT}"
```

### change container image using a serviceaccount

```bash
NAMESPACE="production"
SERVICE_ACCOUNT="my-service-account"
SECRET_NAME=$(kubectl --namespace "${NAMESPACE}" get --output json serviceaccounts "${SERVICE_ACCOUNT}" | jq --raw-output '.secrets[0].name')
TOKEN=$(kubectl --namespace "${NAMESPACE}" get --output json secrets "${SECRET_NAME}" | jq --raw-output '.data.token' | base64 --decode)

DEPLOYMENT="my-app"
CONTAINER_NAME="my-app"
IMAGE_NAME="nginx"
IMAGE_TAG="1.10"

KUBECONFIG='none' \
kubectl --insecure-skip-tls-verify=false \
      --server=${MASTER_ADDRESS} \
      --token="${TOKEN}" \
      --namespace "${NAMESPACE}" \
      set image deployments.apps/"${DEPLOYMENT}" "${CONTAINER_NAME}"="${IMAGE_NAME}:${IMAGE_TAG}"
```

## jobs

### create job from cronjob

```bash
NAMESPACE="production"
CRONJOB="my-app"
kubectl --namespace="${NAMESPACE}" create job --from=cronjob/"${CRONJOB}" "${CRONJOB}"-manual
```

### pause cronjob

```bash
NAMESPACE="production"
CRONJOB="my-app"
kubectl --namespace="${NAMESPACE}" patch cronjobs --from=cronjob/"${CRONJOB}" "${CRONJOB}"-manual
kubectl patch cronjobs <job-name> --patch'{"spec": {"suspend": true}}'
```