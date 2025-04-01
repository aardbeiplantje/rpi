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
variable "TAG_SHA" {
  default = "latest"
}
target "build" {
  pull = true
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
    "linux/arm/v6"
  ]
  args = {
    ARCH = "linux/armhf"
    TAR  = "rpi_zero_w_bookworm.tar.gz"
    TAR_SHA = "6a290a44ab7084c74f60dd0569deb046fc32e14516046bcbd7e6a3aa46ca1150c5620a04a6eb6baf58e5e411e0ccfc43a023167070f758be799e0de8223c9477"
  }
}

target "release" {
  inherits = ["build"]
  output = [
    "type=image,name=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:${DOCKER_TAG},push=true",
    "type=image,name=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/raspbian:${TAG_SHA},push=true"
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
