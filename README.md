# agentic-rag-platform

## Install the infrastructure



### Create  Kind Cluster and Kubernetes namespace via Terraform

Initialize using
```bash
cd terraform/
GODEBUG=netdns=go terraform init -upgrade
terraform plan
terraform apply
```

Test K8s : 
```bash
kubectl get nodes -n rag
kubectl get pods -n rag
```

### Deploy Ollama via kubectl (LLM inference)
```bash
kubectl apply -f k8s/ollama.yaml
```

Test Ollama : 
```bash
kubectl port-forward svc/ollama 11434:11434  -n rag
curl http://localhost:11434

```

Pull a model : 
```bash
kubectl exec -it deployment/ollama -n rag -- bash
ollama pull llama3:latest
```


### Deploy Qdrant  (vector DB) via Helm
```bash
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm install qdrant qdrant/qdrant -n rag
```
To do a sanity check

```bash
export POD_NAME=$(kubectl get pods --namespace rag -l "app.kubernetes.io/name=qdrant,app.kubernetes.io/instance=qdrant" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace rag port-forward $POD_NAME 6333:6333
curl 127.0.0.1:6333
```

### Deploy Redis via Helm

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis -n rag
```

### Structure
```bash
Terraform
   ├── Kind Kubernetes Cluster
   └── Namespace: rag

Kubernetes
   └── Ollama (LLM)

Helm
   ├── Qdrant (Vector DB)
   └── Redis Cache
```
