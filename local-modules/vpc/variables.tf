variable "cidr" {
  type = string
}
variable "tags" {
  type = object({
    Name        = string
    Environment = string
  })
}
variable "azs" {
  type = list(string)
}
variable "enable_dns_hostnames" {
  type = bool
}
variable "enable_dns_support" {
  type = bool
}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
