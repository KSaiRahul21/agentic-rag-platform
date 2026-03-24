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

Create a local volume for persistance, I used the following path, you can adjust the deployment manifest accordingly if needed
```bash
mkdir -p /Users/kwr/ollama-models
```
Deploy Ollama into K8s
```bash
kubectl apply -f terraform/k8s/ollama.yaml
```
This also adds Volume Persistance
```
/Users/kwr/ollama-models  (local path)
  └── /var/ollama-models  (kind container, via extraMounts)
        └── /root/.ollama (pod, via PV/PVC mount)
```

Test Ollama : 
```bash
kubectl get pods -n rag # check if ollama is running 
kubectl port-forward svc/ollama 11434:11434  -n rag
curl http://localhost:11434

```


Pull a model : 
```bash
kubectl exec -it deployment/ollama -n rag -- bash
ollama pull llama3:latest
# or
kubectl exec -n rag deployment/ollama -- ollama pull llama3:latest
```



### Deploy Qdrant  (vector DB) via Helm
```bash
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm install qdrant qdrant/qdrant -n rag

# TODO: change to node port 
kubectl get svc qdrant -n rag
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


## Install the packages 

we use uv package manager


```bash
uv install
source .venv/bin/activate
```


## Run the code

### Start the services

To port forward qdrant and ollama, execute
```bash
kubectl port-forward svc/qdrant 6333:6333 -n rag
kubectl port-forward svc/ollama 11434:11434 -n rag

```

To run the code, execute

```bash
python rag_api/app/rag_pipeline.py
```