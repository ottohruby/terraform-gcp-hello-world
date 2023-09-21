variable "gcp_service_list"{
  type = list(string)
  default= [
    "cloudresourcemanager.googleapis.com",
    "apikeys.googleapis.com"]
}
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = "otto-hruby-test"
  service = each.key
}

module "data_logger" {
  source = "./data_logger"
  depends_on = [google_project_service.gcp_services]
}

module "pubsub-data-logger-events" {
  source = "./pubsub-data-logger-events"
  depends_on = [google_project_service.gcp_services]
}
