resource "google_apikeys_key" "maps" {
  project      = "otto-hruby-test"
  name         = "pubsub-data-logger-events-key"
  display_name = "Api key for pubsub-data-logger topic"

  restrictions {
        # Whitelist only API for pubsub
        api_targets {
            service = "pubsub.googleapis.com"
        }
  }
}

resource "google_pubsub_topic" "example" {
  name = "data-logger-events"
  message_retention_duration = "86600s"
}

resource "google_pubsub_topic_iam_binding" "binding" {
  project = "otto-hruby-test"
  topic = "data-logger-events"
  role = "roles/pubsub.publisher"
  members = [
    "allUsers"
  ]

  depends_on = [
    google_pubsub_topic.example
  ]
}

#data = resource.google_apikeys_key.maps-api-key.key_string



