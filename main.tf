/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_vertex_ai_reasoning_engine" "main" {
  provider = google-nightly
  display_name = var.display_name
  description  = var.description
  region       = var.region
  project      = var.project_id

  spec {
    container_spec {
      image_uri = var.image_uri #"us-central1-docker.pkg.dev/${data.google_project.project.project_id}/vertex-byoc/byoc-agent:latest" # image path
    }
  }

  depends_on = [google_project_iam_member.vertex_ar_reader, google_project_iam_member.tenant_ar_reader]
}


# Provision and retrieve the tenant service agent through another agent
resource "google_vertex_ai_reasoning_engine" "tenant_mds" {
  provider = google-nightly
  display_name = coalesce(var.display_name, "-mds")
  region       = var.region
  project      = var.project_id

  spec {
    source_code_spec {
      inline_source {
        source_archive = filebase64("./test-fixtures/mds_agent_src.tar.gz")
      }

      python_spec {
        entrypoint_module = "metadata_agent"
        entrypoint_object = "root_agent"
      }
    }
  }
}

data "google_vertex_ai_reasoning_engine_query" "tenant_mds" {
  provider = google-nightly
  project             = var.project_id
  region              = var.region
  reasoning_engine_id = google_vertex_ai_reasoning_engine.tenant_mds.name
}

data "google_project" "project" {
  project_id          = var.project_id
}

resource "google_project_iam_member" "vertex_ar_reader" {
  project = data.google_project.project.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-aiplatform-re.iam.gserviceaccount.com"
  depends_on = [data.google_vertex_ai_reasoning_engine_query.tenant_mds]
}

resource "google_project_iam_member" "tenant_ar_reader" {
  project = data.google_project.project.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${jsondecode(data.google_vertex_ai_reasoning_engine_query.tenant_mds.output).output}"
}
