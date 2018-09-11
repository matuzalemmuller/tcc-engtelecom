
Install minikube & kubectl: https://kubernetes.io/docs/tasks/tools/install-minikube/

Start minikube:

```bash
minikube start
```

Deploy the rook operator and cluster:
```bash
kubectl create -f operator.yaml
kubectl create -f rook-cluster.yaml
```