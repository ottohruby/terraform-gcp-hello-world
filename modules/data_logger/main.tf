data "google_project" "project" {
    project_id= "otto-hruby-test"
}

resource "google_service_account" "service_account" {
  account_id   = "data-logger"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/pubsub.publisher"
}

resource "google_cloud_run_service" "default" {
  project = "otto-hruby-test"
  name     = "hello"
  location = "europe-west1"

  metadata {
    namespace = "otto-hruby-test"
  }

  service_account_name = google_service_account.service_account.name

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

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = "europe-west1"
  project     = "otto-hruby-test"
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_domain_mapping" "default" {
  project = "otto-hruby-test"
  location = "europe-west1"
  name     = "dp-logger.ottohruby.cz"

  metadata {
    namespace = "otto-hruby-test"
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}






