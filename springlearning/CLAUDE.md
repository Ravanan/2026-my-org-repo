# springlearning

Minimal Spring Boot 4.0.5 / Java 17 REST app used as a deployment learning playground. Exposes one endpoint (`GET /api/hello`) on port `8082`.

## Code

- [src/main/java/com/learning/springlearning/SpringlearningApplication.java](src/main/java/com/learning/springlearning/SpringlearningApplication.java) — `@SpringBootApplication` entry point.
- [src/main/java/com/learning/springlearning/APIController.java](src/main/java/com/learning/springlearning/APIController.java) — `@RestController` exposing `/api/hello`.
- [src/main/java/com/learning/springlearning/HelloService.java](src/main/java/com/learning/springlearning/HelloService.java) — `@Service` returning the greeting string.
- [src/main/resources/application.properties](src/main/resources/application.properties) — sets `server.port=8082`.

## Build & run

```bash
./mvnw -B clean package        # produces target/springlearning-0.0.1-SNAPSHOT.jar
java -jar target/*.jar         # runs on :8082
```

Docker (multi-stage, see [Dockerfile](Dockerfile)):
```bash
docker build -t springlearning .
docker run -p 8082:8082 springlearning
```

## CI/CD

- [Jenkinsfile](Jenkinsfile) — declarative pipeline. Stages: Checkout → Build (Maven in Docker) → Archive jar → Build image → Push to `docker.io/mailravan/springlearning:<BUILD_NUMBER>` → SSH deploy. Push and deploy stages are gated on `DOCKER_REGISTRY` and `DEPLOY_HOST` env vars.
- Argo CD picks up manifest changes from this repo via the `ApplicationSet`s in [../ArgoCD-test/](../ArgoCD-test/).

## Kubernetes manifests — three parallel formats

This module ships three different ways to deploy the same app. Pick one when making changes:

| Format | Path | Used by |
|---|---|---|
| Kustomize base + overlays | [base/](base/), [overlays/dev/](overlays/dev/), [overlays/prod/](overlays/prod/) | [ArgoCD-test/applicationSet.yaml](../ArgoCD-test/applicationSet.yaml) (git generator) |
| Flat YAML | [yaml-files/](yaml-files/) | [ArgoCD-test/applicationSet_Dev_PROD.yaml](../ArgoCD-test/applicationSet_Dev_PROD.yaml) (list generator) |
| Helm chart | [charts/](charts/) | not currently wired into an `ApplicationSet` |

Keep these in sync when changing image tag, port, or replica count — there's no single source of truth between them.

### Notable image/port detail

- [base/deployment.yaml](base/deployment.yaml) hard-codes `image: mailravan/springlearning:8` and `containerPort: 8080`.
- The app actually listens on `8082` ([application.properties](src/main/resources/application.properties)) and [Dockerfile](Dockerfile) `EXPOSE`s `8082`.

The `containerPort: 8080` / app `:8082` mismatch is a latent bug — fix this if you touch the deployment.

## Tests

```bash
./mvnw test
```

Only [src/test/java/com/learning/springlearning/SpringlearningApplicationTests.java](src/test/java/com/learning/springlearning/SpringlearningApplicationTests.java) — a context-load smoke test.
