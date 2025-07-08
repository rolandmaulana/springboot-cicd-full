provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = "springboot-cicd-full"   # nama app
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "noauth" {
  location        = google_cloud_run_service.default.location
  project         = google_cloud_run_service.default.project
  service         = google_cloud_run_service.default.name
  role            = "roles/run.invoker"
  member          = "allUsers"
}

output "cloud_run_url" {
  value = google_cloud_run_service.default.status[0].url
}
