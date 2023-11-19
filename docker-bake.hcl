# Reference: https://docs.docker.com/build/bake/reference/

group "prod" {
    targets = ["app"]
}

group "dev" {
    targets = ["php-dev"]
}

// Can be any mirror from https://mirrors.alpine.org/, e.g. https://mirror.yandex.ru/mirrors/alpine/
variable "ALPINE_REPO" {
    default = null
}

variable "USER_ID" {
    default = null
}

variable "GROUP_ID" {
    default = null
}

target "app" {
    tags = [
        "ghcr.io/hustlahusky/symfony-demo-app/app:latest"
    ]
    cache-from = [
        "ghcr.io/hustlahusky/symfony-demo-app/app:latest"
    ]
    dockerfile = "Dockerfile"
    target = "php-prod"
    args = {
        ALPINE_REPO = "${ALPINE_REPO}"
        USER_ID = "${USER_ID}"
        GROUP_ID = "${GROUP_ID}"
    }
}

target "php-dev" {
    tags = [
        "ghcr.io/hustlahusky/symfony-demo-app/php-dev:latest"
    ]
    cache-from = [
        "ghcr.io/hustlahusky/symfony-demo-app/php-dev:latest"
    ]
    dockerfile = "Dockerfile"
    target = "php-dev"
    args = {
        ALPINE_REPO = "${ALPINE_REPO}"
        USER_ID = "${USER_ID}"
        GROUP_ID = "${GROUP_ID}"
    }
}
