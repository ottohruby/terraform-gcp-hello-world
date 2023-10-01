data "google_project" "project" {
    project_id= "otto-hruby-test"
}

resource "google_service_account" "service_account" {
  account_id   = "data-logger"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "otto-hruby-test"
  location = "europe-west1"
  ingress = "INGRESS_TRAFFIC_ALL"

  service_account = google_service_account.service_account.name

  template {
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






