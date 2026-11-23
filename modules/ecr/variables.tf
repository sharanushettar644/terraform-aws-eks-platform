variable "name_prefix" {
  description = "Prefix for repository names, e.g. the environment name."
  type        = string
}

variable "repositories" {
  description = "Repository names to create."
  type        = list(string)
  default     = []
}

variable "max_image_count" {
  description = "Maximum number of images to keep per repository."
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Allow deleting repositories that still contain images (handy for dev)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every repository."
  type        = map(string)
  default     = {}
}
