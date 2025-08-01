target "base" {
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/automattic/vip-container-images/php-helpers:latest"]
  platforms  = ["linux/amd64", "linux/arm64"]
  pull       = true
  output = [
    "type=docker"
  ]

  cache-from = [
    "type=gha,scope=php-helpers"
  ]

  cache-to = [
    "type=gha,mode=max,scope=php-helpers"
  ]
}

target "mydumper" {
  inherits = ["base"]
  target   = "build-mydumper"
}

target "php81" {
  inherits = ["base"]
  target   = "php81"
}

target "php82" {
  inherits = ["base"]
  target   = "php82"
}

target "php83" {
  inherits = ["base"]
  target   = "php83"
}

target "php84" {
  inherits = ["base"]
  target   = "php84"
}

target "default" {
  inherits = ["base"]
  output = [
    "type=local,dest=IMAGE",
  ]
}
