# my-ai-doctor
Demo system for secure integration solution

### Add custom domain to /etc/hosts
We have six servers running locally, and if we all use `localhost` with different port numbers,
it will mess up browser cookies. So we use custom domain for each server,
and add following to your `/etc/hosts` file:

```
127.0.0.1 uui.mydoctor
127.0.0.1 api.mydoctor
127.0.0.1 auth.mydoctor
127.0.0.1 ui.myhealth
127.0.0.1 api.myhealth
127.0.0.1 auth.myhealth
```

For windows, add to `%windir%\system32\drivers\etc\hosts` file.


## Run local dev

Start postgreSQL, ollama, weaviate, keycloak servers
```
docker compose -f local-dev.yml up -d
```

Then start ui and api servers individually.

## Run demo
If first time, build with docker for each app, and download ollama models:
```
./dbuild.sh
docker compose up -d
docker exec -it ollama ollama pull nomic-embed-text
docker exec -it ollama ollama pull llama3.2
```

Later can only run
```
docker compose up -d
```

Then open http://ui.mydoctor to chat with AI Doctor!
