resource "helm_release" "qdrant" {

  name       = "qdrant"
  repository = "https://qdrant.github.io/qdrant-helm"
  chart      = "qdrant"
  namespace = "rag"

}