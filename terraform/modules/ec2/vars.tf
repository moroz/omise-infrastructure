variable "namespace" {
  type = string
}

variable "server_ami" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "storage_size" {
  type    = number
  default = 30
}

variable "permitted_buckets" {
  type    = list(string)
  default = []
}
