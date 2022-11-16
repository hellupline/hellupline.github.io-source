---
title: 'kubernetes'

---


## kubernetes plugins

[Dashboard Repository](https://github.com/kubernetes/dashboard)

[Metrics Server Repository](https://github.com/kubernetes-sigs/metrics-server)

[Local Path Provisioner Repository](https://github.com/rancher/local-path-provisioner)

[Cert Manager Repository](https://github.com/cert-manager/cert-manager)

[Proxied Dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

[Official Cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

```bash
# Dashboard
kubectl apply --filename https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Metrics Server
kubectl apply --filename https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml
kubectl get --output jsonpath='{.status.conditions[*].message}' apiservice v1beta1.metrics.k8s.io

# Local Path Provisioner
kubectl apply --filename https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.23/deploy/local-path-storage.yaml

# Cert Manager
kubectl apply --filename https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
kubectl apply --filename https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml

# Proxy
kubectl proxy

# ServiceAccount Token
kubectl -n kube-system get -o json secret \
    | jq --raw-output '.items[] | select(.metadata.name | startswith("default")) | .data.token' \
    | base64 --decode | xcopy

# ServiceAccount Token EKS
kubectl -n kube-system get -o json secret \
    | jq --raw-output '.items[] | select(.metadata.name | startswith("eks-admin")) | .data.token' \
    | base64 --decode | xcopy

# EKS Token
aws eks get-token --cluster-name "my_cluster" | jq --raw-output '.status.token'
```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

```bash
kubectl -n kubernetes-dashboard create token admin-user
```


## pods

### how execute docker image in kubernetes

```bash
NAMESPACE="production"
SERVICE="my-app"
kubectl run --rm -it shell --generator=run-pod/v1 --image=bash
    $ wget -qO- http://${SERVICE}.${NAMESPACE}.svc.cluster.local
    $ wget -qO- https://www.google.com
kubectl attach -it shell -c shell
```


### how to read deployment/pod logs

```bash
NAMESPACE="production"

DEPLOYMENT="my-app"
kubectl --namespace="${NAMESPACE}" logs --tail=1 --follow "deployment/${DEPLOYMENT}"

POD="my-app"
kubectl --namespace="${NAMESPACE}" logs --tail=1 --follow "${POD}"
```


### how to access a kubernetes service/pod

```bash
NAMESPACE="production"
LOCAL_PORT="8080"

SERVICE="my-app"
SERVICE_PORT="80"
kubectl --namespace="${NAMESPACE}" port-forward "services/${SERVICE}" "${LOCAL_PORT}:${SERVICE_PORT}"

POD="my-app"
POD_PORT="80"
kubectl --namespace="${NAMESPACE}" port-forward "pods/${POD}" "${LOCAL_PORT}:${POD_PORT}"
```


### run command in a pod from a deployment

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
POD_LABEL=${$(kubectl get deployments "${DEPLOYMENT}" --output=json | jq -j '.spec.selector.matchLabels | to_entries | .[] | "\(.key)=\(.value),"')%?}
POD_NAME=$(kubectl --namespace="${NAMESPACE}" get --output jsonpath='{.items[0].metadata.name}' pods --selector="${POD_LABEL}")
kubectl --namespace="${NAMESPACE}" exec -it "${POD_NAME}" -- bash
```


### copy from/to pods from a deployment

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
POD_LABEL=${$(kubectl --namespace="${NAMESPACE}" get deployments "${DEPLOYMENT}" --output=json | jq -j '.spec.selector.matchLabels | to_entries | .[] | "\(.key)=\(.value),"')%?}
POD_NAME=$(kubectl --namespace="${NAMESPACE}" get --output jsonpath='{.items[0].metadata.name}' pods --selector="${POD_LABEL}")

kubectl --namespace="${NAMESPACE}" cp "${POD_NAME}:/etc/letsencrypt" 'etc-letsencrypt'
kubectl --namespace="${NAMESPACE}" cp "${POD_NAME}:/etc/nginx/conf.d" 'etc-nginx-conf.d'

kubectl --namespace="${NAMESPACE}" cp 'etc-letsencrypt' "${POD_NAME}:/etc/letsencrypt"
kubectl --namespace="${NAMESPACE}" cp 'etc-nginx-conf.d' "${POD_NAME}:/etc/nginx/conf.d"
```


### show failed pods

```bash
NAMESPACE="production"
kubectl --namespace="${NAMESPACE}" get pods --field-selector=status.phase=Failed
kubectl get pods --all-namespaces --field-selector=status.phase=Failed
```


## deployment

### change deployment image

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
CONTAINER_NAME="my-app"
IMAGE_NAME="nginx"
IMAGE_TAG="1.10"
kubectl --namespace="${NAMESPACE}" set image --record "deployment.apps/${DEPLOYMENT}" "${CONTAINER_NAME}=${IMAGE_NAME}:${IMAGE_TAG}"
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
kubectl --namespace "${NAMESPACE}" rollout status --watch deployment.apps/"${DEPLOYMENT}"
```


### deployment history

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${namespace}" rollout history deployment.apps/"${deployment}"
```


### deployment revert

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"

# target revision
kubectl --namespace "${NAMESPACE}" rollout undo deployment.apps/"${DEPLOYMENT}" --to-revision=2

# previous
kubectl --namespace "${NAMESPACE}" rollout undo deployment.apps/"${DEPLOYMENT}"
```


### deployment restart all pods

```bash
NAMESPACE="production"
DEPLOYMENT="my-app"
kubectl --namespace "${NAMESPACE}" rollout restart deployment.apps/"${DEPLOYMENT}"
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


## others

### cluster items

```bash
kubectl get --all-namespaces deployments,cronjobs,jobs,services,ingresses,pods,configmaps,secrets
```


### cluster usage

```bash
kubectl top nodes
kubectl top pods
```


### watch cluster events

```bash
kubectl get events --watch --all-namespaces
```


### pods resource requests/limit report

```bash
NAMESPACE="production"
kubectl --namespace=${NAMESPACE} get --output json pods | jq -r '.items[] |
"\(.metadata.name)
    Req. RAM: \(.spec.containers[].resources.requests.memory)
    Lim. RAM: \(.spec.containers[].resources.limits.memory)
    Req. CPU: \(.spec.containers[].resources.requests.cpu)
    Lim. CPU: \(.spec.containers[].resources.limits.cpu)
    Req. Eph. DISK: \(.spec.containers[].resources.requests["ephemeral-storage"])
    Lim. Eph. DISK: \(.spec.containers[].resources.limits["ephemeral-storage"])
"'
```


### kubectl using service-account token

```bash
NAMESPACE="production"
SERVICE_ACCOUNT="my-service-account"
SECRET_NAME="$(kubectl --namespace "${NAMESPACE}" get --output jsonpath='{.secrets[*].name}' serviceaccounts "${SERVICE_ACCOUNT}")"
TOKEN="$(kubectl --namespace "${NAMESPACE}" get --output jsonpath="{.data.token}" secrets "${SECRET_NAME}" | base64 --decode)"
MASTER_ADDRESS="$(kubectl config -o json view | jq --raw-output  '. as $root | $root.clusters[] | select(.name == ($root.contexts[] | select(.name == $root["current-context"]) | .context.cluster)) | .cluster.server')"

KUBECONFIG='none' \
kubectl --insecure-skip-tls-verify=false --server="${MASTER_ADDRESS}" --token="${TOKEN}" --namespace "${NAMESPACE}" get pods
```
