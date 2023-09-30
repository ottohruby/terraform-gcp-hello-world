data "google_project" "project" {
    project_id= "otto-hruby-test"
}

#resource "google_apikeys_key" "maps" {
#  project      = "otto-hruby-test"
#  name         = "pubsub-data-logger-events-key"
#  display_name = "pubsub-data-logger-events-key"

#  restrictions {
#        # Whitelist only API for pubsub
#        api_targets {
#            service = "pubsub.googleapis.com"
#        }
#  }
#}

resource "google_pubsub_topic" "example" {
  project = data.google_project.project.project_id
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


resource "google_pubsub_subscription" "example" {
  project = data.google_project.project.project_id
  name  = "example-subscription"
  topic = google_pubsub_topic.example.name

  message_retention_duration = "1800s" # 30 minutes

  ack_deadline_seconds = 20

  enable_message_ordering    = false
}

resource "google_pubsub_subscription" "bigquery" {
  project = data.google_project.project.project_id
  name  = "bigquery"
  topic = google_pubsub_topic.example.name

  bigquery_config {
    table = "${google_bigquery_table.test.project}.${google_bigquery_table.test.dataset_id}.${google_bigquery_table.test.table_id}"
  }

  depends_on = [google_project_iam_member.viewer, google_project_iam_member.editor]
}


resource "google_project_iam_member" "viewer" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.metadataViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "editor" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset" "test" {
  project = data.google_project.project.project_id
  dataset_id = "example_dataset"
}

resource "google_bigquery_table" "test" {
  project = data.google_project.project.project_id
  deletion_protection = false
  table_id   = "example_table"
  dataset_id = google_bigquery_dataset.test.dataset_id

  schema = <<EOF
[
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  }
]
EOF
}


#data = resource.google_apikeys_key.maps-api-key.key_string



