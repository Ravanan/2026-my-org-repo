# 2026-my-org-repo

GitOps monorepo containing a Spring Boot learning app and its Argo CD deployment manifests.

## Layout

- [springlearning/](springlearning/) — Spring Boot 4.0.5 / Java 17 application. Source, Dockerfile, Jenkinsfile, Helm chart, and Kustomize base/overlays live here.
- [ArgoCD-test/](ArgoCD-test/) — Argo CD `ApplicationSet` manifests that point Argo CD back at this repo to deploy the app to dev/prod namespaces.

## Remote

GitHub: `https://github.com/Ravanan/2026-my-org-repo.git` (branch `main`).

This GitHub URL is hardcoded in both [springlearning/Jenkinsfile](springlearning/Jenkinsfile) (checkout stage) and the Argo CD `ApplicationSet`s in [ArgoCD-test/](ArgoCD-test/) (as `repoURL`). If the repo is ever renamed or moved to a different GitHub org, update all those references together.

## Typical workflows

- **Build / deploy app:** edit code in [springlearning/src/](springlearning/src/), Jenkins builds the image and pushes to `docker.io/mailravan`, Argo CD syncs the new manifests to the cluster.
- **Change deployment topology:** edit [springlearning/overlays/dev/](springlearning/overlays/dev/) or [springlearning/overlays/prod/](springlearning/overlays/prod/) (Kustomize), or [springlearning/charts/](springlearning/charts/) (Helm).
- **Change which clusters/namespaces Argo CD targets:** edit the `ApplicationSet` files in [ArgoCD-test/](ArgoCD-test/).

See each subdirectory's `CLAUDE.md` for module-specific details.
