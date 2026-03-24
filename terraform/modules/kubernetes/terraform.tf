terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.11.0"
    }

  }
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.rag_cluster.endpoint
    cluster_ca_certificate = kind_cluster.rag_cluster.cluster_ca_certificate
    client_certificate     = kind_cluster.rag_cluster.client_certificate
    client_key             = kind_cluster.rag_cluster.client_key
  }
}

