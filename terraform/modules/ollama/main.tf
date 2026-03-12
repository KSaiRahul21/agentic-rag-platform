resource "kubernetes_deployment_v1" "ollama" {

  metadata {
    name      = "ollama"
    namespace = "rag"

    labels = {
      app = "ollama"
    }
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

        }

      }

    }

  }

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

    type = "ClusterIP"

  }

}