variable "profile" {
  description = "The AWS profile to use"
  default     = "default"
  type        = string
}

variable "create_vpc" {
  description = "Create a new VPC"
  default     = true
  type        = bool
}