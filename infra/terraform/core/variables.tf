variable "aws_region" {
    description = "AWS region used for core infrastructure resources"
    type       = string
    default = "eu-central-1"
}

variable "project" {
    description = "Project name used for tagging and naming resources"
    type       = string
    default = "boardgames"
}

variable "environment" {
    description = "Environment name used for tagging and naming resources"
    type       = string
    default = "dev"
}

variable "component" {
    description = "Component name used for tagging and naming resources"
    type       = string
    default = "core"
}
