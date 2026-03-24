resource "kubernetes_persistent_volume_v1" "ollama" {
  depends_on = [module.kubernetes_cluster]

  metadata {
    name = "ollama-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "manual"

    persistent_volume_source {
      host_path {
        path = "/var/ollama-models"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "ollama" {
  metadata {
    name      = "ollama-pvc"
    namespace = "rag"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "manual"

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.rag,
    kubernetes_persistent_volume_v1.ollama
  ]
}

resource "kubernetes_deployment_v1" "ollama" {
  metadata {
    name      = "ollama"
    namespace = "rag"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ollama"
      }
    }

    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }

      spec {
        container {
          name  = "ollama"
          image = "ollama/ollama"

          port {
            container_port = 11434
          }

          volume_mount {
            name       = "ollama-storage"
            mount_path = "/root/.ollama"
          }
        }

        volume {
          name = "ollama-storage"

          persistent_volume_claim {
            claim_name = "ollama-pvc"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim_v1.ollama]
}

resource "kubernetes_service_v1" "ollama" {
  metadata {
    name      = "ollama"
    namespace = "rag"
  }

  spec {
    selector = {
      app = "ollama"
    }

    port {
      port        = 11434
      target_port = 11434
    }
  }

  depends_on = [kubernetes_deployment_v1.ollama]
}
