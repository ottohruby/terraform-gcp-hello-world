resource "google_cloud_run_service" "default" {
  project = "otto-hruby-test"
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
