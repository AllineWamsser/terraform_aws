variable "project_name" {
  description = "grocery_mate"
  type        = string

}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  type        = string

}

variable "public_key" {
  description = "caminho para a chave"
  type        = string

}
variable "vpc_id" {
  description = "id da vpc existente"
  type        = string

}

variable "public_subnets" {
  description = "lista de subents"
  type        = list(string)

}