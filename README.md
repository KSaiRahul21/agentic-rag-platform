# agentic-rag-platform

## Install the infrastructure

Terraform installs everything

### Structure
```bash
Terraform
   ├── Kind Kubernetes Cluster
   └── Namespace: rag
         ├── Qdrant (Vector DB)
         ├── Ollama (LLM)
         └── Redis Cache   
```

### Create infrastructure 

Initialize using
```bash
cd terraform/
terraform init -upgrade
terraform plan
terraform state rm $(terraform state list)
terraform apply
```

Test K8s : 
```bash
kubectl get nodes -n rag
kubectl get pods -n rag
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

Test Qdrant

```bash
export POD_NAME=$(kubectl get pods --namespace rag -l "app.kubernetes.io/name=qdrant,app.kubernetes.io/instance=qdrant" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace rag port-forward $POD_NAME 6333:6333
curl 127.0.0.1:6333
```


## Shutdown Infrastructure

```bash
terraform destroy
terraform state rm $(terraform state list)
kind delete cluster --name rag-platform
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
kubectl port-forward svc/qdrant 6333:6333 -n rag &
kubectl port-forward svc/ollama 11434:11434 -n rag

```

To run the code, execute

```bash
python rag_api/app/rag_pipeline.py
```