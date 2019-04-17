workflow "Build and push to Docker" {
  resolves = [
    "docker push sha",
  ]
  on = "pull_request"
}

action "check -  deploy label" {
  uses = "actions/bin/filter@master"
  args = "label deploy"
}

action "docker login" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
  needs = ["check -  deploy label"]
}

action "docker build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "build -t $SOURCE_IMAGE ."
  secrets = ["SOURCE_IMAGE"]
  needs = ["check -  deploy label"]
}

action "docker tag" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = [
    "docker build",
    "docker login",
  ]
  args = "$SOURCE_IMAGE $TARGET_IMAGE"
  secrets = ["TARGET_IMAGE", "SOURCE_IMAGE"]
}

action "docker push sha" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["docker tag"]
  args = "push $TARGET_IMAGE:$IMAGE_SHA"
  secrets = ["TARGET_IMAGE"]
}

workflow "Clean up" {
  on = "pull_request"
  resolves = ["check - PR closed"]
}

action "check - PR closed" {
  uses = "actions/bin/filter@4227a6636cb419f91a0d1afb1216ecfab99e433a"
  args = "action closed"
}
