workflow "Build and push to Docker" {
  resolves = [
    "docker push sha",
  ]
  on = "pull_request"
}

action "label added - deploy" {
  uses = "actions/bin/filter@master"
  args = "label deploy"
}

action "docker login" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = [ 
    "label added - deploy" 
  ]
  secrets = [
    "DOCKER_PASSWORD",
    "DOCKER_USERNAME",
  ]
}

action "docker build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = [
    "docker login"
  ]
  args = "build -t $SOURCE_IMAGE ."
  secrets = ["SOURCE_IMAGE"]
}

action "docker tag" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["docker build"]
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
  resolves = ["PR closed"]
}

action "PR closed" {
  uses = "actions/bin/filter@4227a6636cb419f91a0d1afb1216ecfab99e433a"
  args = "action closed"
}
