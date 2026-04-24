# Dockerfile for springlearning
# Simple runtime image that expects a packaged Spring Boot jar in target/

FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copy the application jar (artifactId-version as defined in pom.xml)
# Build locally with: mvn -DskipTests package
COPY target/springlearning-0.0.1-SNAPSHOT.jar app.jar

# Run as non-root user
RUN groupadd -r spring && useradd -r -g spring spring && chown -R spring:spring /app
USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
