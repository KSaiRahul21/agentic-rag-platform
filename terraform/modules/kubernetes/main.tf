resource "kind_cluster" "rag_cluster" {
  name = "rag-platform"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_mounts {
        host_path      = "/Users/kwr/ollama-models"
        container_path = "/var/ollama-models"
      }
    }
  }
}