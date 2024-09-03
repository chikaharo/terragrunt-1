variable "vpc_id" {
  type = string
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["183.91.3.171/32", "118.70.135.21/32", "18.139.91.188/32"]
}
