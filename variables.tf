/**
 * Copyright 2025 Google LLC
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

variable "display_name" {
  description = "The display name of the Reasoning Engine."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "region" {
  description = "The region of the reasoning engine. eg us-central1."
  type        = string
  default     = "us-central1"
}

variable "description" {
  description = "The description of the Reasoning Engine."
  type        = string
  default     = null
}

variable "image_uri" {
  description = "The Artifact Registry Container Image URI."
  type        = string
}
