# FacsimiLab GH Runner

Repository for building a self hosted GitHub runner based off FacsimiLab and Ubuntu images

```sh
docker buildx create --name cuda --node cuda --use --bootstrap --driver-opt network=docker-local-reg



docker buildx create --name main --node bk15 --use --bootstrap --driver-opt network=docker-local-reg
```