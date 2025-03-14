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

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = []
  type        = list(string)
}