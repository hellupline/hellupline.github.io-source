---
title: Commands
tags:
- utils
weight: 2

---
# Commands

## How execute docker image in kubernetes

```bash
kubectl run --rm -it shell --image=alpine --restart=Never -- wget -qO- https://www.google.com
```

## How to run command in a deployments pod

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
POD_LABEL=$(kubectl --namespace="${NAMESPACE}" get deployments "${DEPLOYMENT}" --output=jsonpath='{.spec.template.metadata.labels.app}')
POD_NAME=$(kubectl --namespace="${NAMESPACE}" get pods --selector=app="${POD_LABEL}" --output=jsonpath='{.items[0].metadata.name}')

kubectl --namespace="${NAMESPACE}" exec -it "${POD_NAME}" -- bash
```

## Change deployment image

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace="${NAMESPACE}" set image deployment/"${DEPLOYMENT}" nginx:1.10
```

## Scale deployment

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" scale deployment --replicas 1 "${DEPLOYMENT}"
```

## Copy from/to pods

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