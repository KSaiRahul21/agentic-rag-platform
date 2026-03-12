# agentic-rag-platform

## Install the infrastructure
Use terraform to establish the local infrastructure

Initialize using
```bash
GODEBUG=netdns=go terraform init -upgrade
terraform plan
terraform apply
```
This will do the following

Create Kubernetes namespace via kind

Deploy Ollama (LLM inference)

Deploy Qdrant (vector DB)


```bash
Terraform
   │
Kind Kubernetes
   │
Namespace: rag
   │
├── Ollama (LLM)
└── Qdrant (Vector DB)
```


Test Ollama : 
```
kubectl port-forward svc/ollama 11434:11434  -n rag
curl http://localhost:11434

```

Pull a model : 
```
kubectl exec -it deployment/ollama -n rag -- bash
ollama pull llama3:latest
```
