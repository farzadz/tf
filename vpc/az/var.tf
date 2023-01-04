variable "vpc_id" {
  description = "vpc to create resources in"
  type        = string
}

variable "availability_zone" {
  description = "availability zone name to configure"
  default     = "us-east-1a"
  type        = string
}

variable "subnet_cidr_block" {
  description = "subnet type to cidr block mapping"
  default     = {
    "reserved" = "10.16.0.0/20"
    "db"       = "10.16.16.0/20"
    "app"      = "10.16.32.0/20"
    "web"      = "10.16.48.0/20"
  }
  type = map(string)
}