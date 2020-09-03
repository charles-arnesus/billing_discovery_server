# temp container to build using gradle
FROM gradle:6.6.1-jdk8 AS TEMP_BUILD_IMAGE
ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
COPY build.gradle settings.gradle $APP_HOME

COPY gradle $APP_HOME/gradle
COPY --chown=gradle:gradle . /home/gradle/src
USER root
RUN chown -R gradle /home/gradle/src

COPY . .
RUN gradle clean build

# Start with a base image containing Java runtime
FROM openjdk:8-jdk-alpine
ENV ARTIFACT_NAME=billing_discovery_server-0.0.1-SNAPSHOT.jar
ENV APP_HOME=/usr/app/

WORKDIR $APP_HOME
COPY --from=TEMP_BUILD_IMAGE $APP_HOME/build/libs/$ARTIFACT_NAME .

EXPOSE 8761
ENTRYPOINT exec java -jar ${ARTIFACT_NAME} billing-discovery-server

