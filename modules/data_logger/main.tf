resource "google_cloud_run_service" "default" {
  name     = "hello"
  location = "eu-west1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}