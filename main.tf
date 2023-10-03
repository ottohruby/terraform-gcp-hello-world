data "gcp_project" "project" {
    project_id = "otto-hruby-test"
    location = "europe-west1"
}


variable "gcp_required_api"{
  type = list(string)
  default= [
    "cloudresourcemanager.googleapis.com",
    "apikeys.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com"
    ]
}
resource "google_project_service" "gcp_api" {
  for_each = toset(var.gcp_required_api)
  project = data.gcp_project.project.project_id
  service = each.key
}

module "data_logger" {
  source = "./modules/data_logger"
  depends_on = [google_project_service.gcp_api]
}

module "pubsub-data-logger-events" {
  source = "./modules/pubsub-data-logger-events"
  depends_on = [google_project_service.gcp_api]
}
