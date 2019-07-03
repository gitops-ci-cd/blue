workflow "Build, push, and deploy" {
  resolves = [
    "docker push sha",
    "git commit create overlay"
  ]
  on = "pull_request"
}

action "check - deploy label" {
  uses = "actions/bin/filter@master"
  args = "label deploy"
}

action "docker login" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["check - deploy label"]
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
}

action "docker build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["check - deploy label"]
  args = "build -t $SERVICE ."
  secrets = ["SERVICE"]
}

action "docker tag" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = [
    "docker build",
    "docker login",
  ]
  args = "$SERVICE $TARGET_IMAGE"
  secrets = [
    "SERVICE",
    "TARGET_IMAGE",
  ]
}

action "docker push sha" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["docker tag"]
  args = "push $TARGET_IMAGE:$IMAGE_SHA"
  secrets = ["TARGET_IMAGE"]
}

action "git commit create overlay" {
  uses = "actions/kustomized-namespace-create-overlay@v0.9.0"
  needs = ["docker tag"]
  secrets = [
    "CLUSTER_REPO",
    "SERVICE",
    "TARGET_IMAGE",
    "TOKEN",
  ]
}

workflow "Clean up" {
  on = "pull_request"
  resolves = ["git commit cleanup overlay"]
}

action "check - PR closed" {
  uses = "actions/bin/filter@4227a6636cb419f91a0d1afb1216ecfab99e433a"
  args = "action closed"
}

action "git commit cleanup overlay" {
  uses = "actions/kustomized-namespace-cleanup-overlay@v0.9.0"
  needs = ["check - PR closed"]
  secrets = [
    "CLUSTER_REPO",
    "TOKEN",
  ]
}
