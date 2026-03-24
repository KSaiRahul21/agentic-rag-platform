module "kubernetes_cluster" {
  source = "./modules/kubernetes"
}

resource "kubernetes_namespace_v1" "rag" {
  depends_on = [module.kubernetes_cluster]
  metadata {
    name = "rag"
  }
}

# Qdrant
resource "helm_release" "qdrant" {
  name       = "qdrant"
  repository = "https://qdrant.github.io/qdrant-helm"
  chart      = "qdrant"
  namespace  = "rag"

  depends_on = [kubernetes_namespace_v1.rag]
}

# Redis
resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  namespace  = "rag"
  timeout    = 600  # 10 minutes

  set = [
    {
      name  = "auth.enabled"
      value = "false"
    },
    {
      name  = "replica.replicaCount"
      value = "0"
    }
  ]

  depends_on = [kubernetes_namespace_v1.rag]
}