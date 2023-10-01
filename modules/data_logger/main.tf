data "google_project" "project" {
    project_id= "otto-hruby-test"
}

resource "google_service_account" "service_account" {
  account_id   = "run-service-data-logger"
}

resource "google_service_account_iam_member" "admin-account-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/pubsub.publisher"
  member             = google_service_account.service_account.email
}

resource "google_cloud_run_v2_service" "default" {
  name     = "data-logger"
  location = "europe-west1"
  ingress = "INGRESS_TRAFFIC_ALL"


  template {
    service_account = google_service_account.service_account.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

resource "google_cloud_run_domain_mapping" "default" {
  project = "otto-hruby-test"
  location = "europe-west1"
  name     = "dp-logger.ottohruby.cz"

  metadata {
    namespace = "otto-hruby-test"
  }

  spec {
    route_name = google_cloud_run_v2_service.default.name
  }
}






