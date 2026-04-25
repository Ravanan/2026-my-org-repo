# Multi-stage Dockerfile for building and running the Spring Boot application
# Stage 1: build with Maven
FROM maven:3.10.1-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the files needed for a Maven build to leverage layer caching
COPY pom.xml ./
COPY src ./src

# Build the application (skip tests by default to speed up builds)
RUN mvn -B -DskipTests package

# Stage 2: minimal runtime image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Expose the port configured in application.properties
EXPOSE 8082

# Copy the packaged jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
