# my-ai-doctor
Demo system for secure integration solution

## Run local dev

Start postgreSQL, ollama, weaviate, keycloak servers
```
docker compose -f local-dev.yml up -d
```

Then start ui and api servers individually.

## Run demo
```
docker compose up -d
```

Then open http://ui.mydoctor to chat with AI Doctor!
