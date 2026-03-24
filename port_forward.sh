# forward.sh
#!/bin/bash
echo "Starting port-forwards..."

kubectl port-forward svc/qdrant 6333:6333 -n rag &
kubectl port-forward svc/ollama 11434:11434 -n rag &
kubectl port-forward svc/redis-master 6379:6379 -n rag &

echo "Qdrant:  http://localhost:6333"
echo "Ollama:  http://localhost:11434"
echo "Redis:   localhost:6379"
echo ""
echo "Press Ctrl+C to stop all"

trap "kill 0" EXIT
wait