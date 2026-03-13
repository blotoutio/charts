# Combined Airflow UI + API ingress (single resource)
# Note: Annotations apply to all paths. Auth (auth-url + Basic header) will apply to both UI and API.
# If you need auth only on the API and not on the UI, keep two separate ingress resources.
resource "kubernetes_ingress_v1" "airflow" {
  metadata {
    name      = "airflow"
    namespace = kubernetes_namespace.etl.id
    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/use-regex"             = "true"
      # Single rewrite: use $1$2$3 to avoid double-slash (e.g. /airflow/ -> /airflow/, /airflow/api/v1/x -> /airflow/api/v1/x)
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/airflow$1$2$3"
      "nginx.ingress.kubernetes.io/configuration-snippet" = "proxy_set_header Authorization \"Basic ${base64encode("${var.airflow_username}:${data.aws_secretsmanager_secret_version.airflow_password.secret_string}")}\";"
      "nginx.ingress.kubernetes.io/auth-url"              = "http://blotoutapi.default.svc.cluster.local:8080/api/v1/auth/validation"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = data.aws_secretsmanager_secret_version.ui_domain.secret_string
      http {
        # Matches both /airflow/... and /airflow/api/v1/... ($1=/api/v1 or empty, $2=/ or empty, $3=rest)
        path {
          backend {
            service {
              name = "airflow"
              port {
                name = "http"
              }
            }
          }
          path = "/airflow(/api/v1)?(/|$)(.*)"
        }
      }
    }
  }
}
