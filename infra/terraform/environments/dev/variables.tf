variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  sensitive   = true
}

variable "app_secret_key" {
  description = "Django SECRET_KEY"
  type        = string
  sensitive   = true
}
