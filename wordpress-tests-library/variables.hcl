variable "WORDPRESS_VERSIONS" {
  default = []
}

variable "push" {
  default = false
}

variable "cache" {
  default = true
}

variable "cache-from" {
  default = []
}

variable "cache-to" {
  default = []
}

variable "platforms" {
  default = []
}
