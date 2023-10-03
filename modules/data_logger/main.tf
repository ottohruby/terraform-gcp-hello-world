

data "gcp_project" "project" {
    project_id = "otto-hruby-test"
    location = "europe-west1"
}





resource "google_service_account" "service_account" {
  account_id   = "run-service--data-logger"
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = data.gcp_project.project.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "data-logger"
  location = data.gcp_project.project.location

  template {
    service_account = google_service_account.service_account.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

resource "google_cloud_run_domain_mapping" "default" {
  project = data.gcp_project.project.project_id
  location = data.gcp_project.project.location
  name     = "dp-logger.ottohruby.cz"

  metadata {
    namespace = "otto-hruby-test"
  }

  spec {
    route_name = google_cloud_run_v2_service.default.name
  }
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}






