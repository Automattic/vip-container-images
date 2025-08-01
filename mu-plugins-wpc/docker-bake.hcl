target "base" {
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  pull       = true
  output = [
    "type=image"
  ]

  cache-from = [
    "type=gha,scope=mu-plugins-wpc"
  ]

  cache-to = [
    "type=gha,mode=max,scope=mu-plugins-wpc"
  ]
}

target "develop" {
  inherits = ["base"]
  tags     = ["ghcr.io/automattic/vip-container-images/mu-plugins-wpc:develop"]
  args = {
    "BRANCH" = "develop-built"
  }
}

target "staging" {
  inherits = ["base"]
  tags     = ["ghcr.io/automattic/vip-container-images/mu-plugins-wpc:staging"]
  args = {
    "BRANCH" = "staging-built"
  }
}

target "production" {
  inherits = ["base"]
  tags     = ["ghcr.io/automattic/vip-container-images/mu-plugins-wpc:production"]
  args = {
    "BRANCH" = "production-built"
  }
}

group "default" {
  targets = [
    "develop",
    "staging",
    "production"
  ]
}
