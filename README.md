# secrets-sidecar
Converts secrets in ECS from environment variables to Docker Compose files under `/run/secrets`.

1. Iterates over all environment variables, checking for prefix `secret_`
2. Creates a file under `/run/secrets` with the name of the environment variable without the prefix
3. Returns non-zero exit code if any of the files fail to be created

You'd want to add this sidecar to your ECS task definition as a non-essential container and add a volume for `/run/secrets`. Then, add `volumeFrom` to your main container.


Test from command line:
```
make build
./secrets
```

Use the existing docker image locally:
```
docker run lionello/secrets-sidecar
```

Build your own docker image:
```
make docker
```

Push all docker images and multi-arch manifest:
```
make push
```
