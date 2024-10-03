ARG TAG=21-jdk-alpine

FROM eclipse-temurin:${TAG} as BUILD

# build distribution
COPY . /src
WORKDIR /src
RUN ./gradlew build -x test
RUN ./gradlew installDist

FROM eclipse-temurin:${TAG}

# setup workdir
ENV APP_DIR=/app
WORKDIR ${APP_DIR}

COPY --from=BUILD /src/build/libs/*.jar app.jar

EXPOSE 80
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
