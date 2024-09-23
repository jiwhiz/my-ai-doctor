# mydoctor-api server
MyDoctor backend API server for demo purpose.

## Test locally

### Build with Gradle

```
./gradlew clean build
```

### Run with local PostgreSQL
```
./gradlew bootRun --args='--spring.profiles.active=dev'
```

Then you can open Swagger UI at http://localhost:8081/swagger-ui/index.html

