resource "google_project" "basic" {
  project_id = "otto-hruby-test"
}

resource "google_apikeys_key" "maps" {
  project      = google_project.basic.project_id
  name         = "pubsub-data-logger-events-key"
  display_name = "Api key for pubsub-data-logger topic"

  restrictions {
        # Whitelist only API for pubsub
        api_targets {
            service = "pubsub.googleapis.com"
        }
  }
}

resource "google_pubsub_topic_iam_binding" "binding" {
  project = google_project.basic.project_id
  topic = "data-logger-events"
  role = "roles/pubsub.publisher"
  members = [
    "allUsers"
  ]
}

#data = resource.google_apikeys_key.maps-api-key.key_string



