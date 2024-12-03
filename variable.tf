variable "aws_profile" {
  description = "default"
  type        = string
}

variable "aws_region" {
  description = "us-east-1"
  type        = string
}

variable "bucket_name" {
  default = "react-s3bucket1203"
  type = string
}

variable "created_by" {
  default = "your name"
  type = string
}

variable "object_ownership" {
  default = "BucketOwnerPreferred"
  type = string
}
