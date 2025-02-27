target "default" {
  name = "wptl-${replace(wp.tag, ".", "-")}"

  matrix = {
    wp = WORDPRESS_VERSIONS
  }

  dockerfile = "Dockerfile"
  context    = "."
  no-cache   = !wp.cacheable && cache

  args = {
    WP_GIT_REF = wp.ref
  }

  tags = [
    "ghcr.io/automattic/vip-container-images/wordpress-tests-library:${wp.tag}"
  ]

  platforms  = platforms
  cache-from = cache-from
  cache-to   = cache-to
}
