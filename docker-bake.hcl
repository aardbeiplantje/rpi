group "default" {
  targets = ["build"]
}
group "release" {
  targets = ["release"]
}
variable "DOCKER_REGISTRY" {
  default = "ghcr.io"
}
variable "DOCKER_REPOSITORY" {
  default = "aardbeiplantje/iot"
}
variable "DOCKER_TAG" {
  default = "latest"
}
target "build" {
  pull = true
  name = "raspbian-${env}"
  matrix = {
    env = ["release"]
  }
  target = "img"
  output = [
    "type=docker,name=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:${DOCKER_TAG}"
  ]
  progress = ["plain", "tty"]
  buildkit = true
  context = "."
  dockerfile = "Dockerfile"
  networks = ["host"]
  platforms = [
    "linux/armhf"
  ]
  args = {
    ARCH = "linux/armhf"
    TAR  = "rpi_zero_w_bookworm.tar.gz"
  }
}

target "release" {
  inherits = ["build"]
  output = [
    "type=image,name=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:${DOCKER_TAG},push=true"
  ]
  cache-to = [
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:cache,mode=max"
  ]
  cache-from = [
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:cache",
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:${DOCKER_TAG}"
  ]
  attest = [
    "type=provenance,mode=max",
    "type=sbom",
  ]
}
