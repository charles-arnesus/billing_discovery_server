# temp container to build using gradle
FROM gradle:5.3.0-jdk-alpine AS TEMP_BUILD_IMAGE
ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
COPY build.gradle settings.gradle $APP_HOME

COPY gradle $APP_HOME/gradle
COPY --chown=gradle:gradle . /home/gradle/src
USER root
RUN chown -R gradle /home/gradle/src

RUN gradle build || return 0
COPY . .
RUN gradle clean build

# Start with a base image containing Java runtime
FROM openjdk:8-jdk-alpine
VOLUME /tmp
EXPOSE 8761
ARG JAR_FILE=./build/libs/billing_discovery_server-0.0.1-SNAPSHOT.jar
ADD ${JAR_FILE} billing_discovery_server.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/billing_discovery_server.jar"]

