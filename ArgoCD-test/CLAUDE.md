# ArgoCD-test

Argo CD `ApplicationSet` manifests that deploy the `springlearning` app (and a sample guestbook app) to one or more Kubernetes clusters.

## Files

- [applicationSet.yaml](applicationSet.yaml) — `git` generator. Discovers overlay directories under `springlearning/overlays/*` and creates one Argo CD `Application` per overlay. Namespace is derived from `{{path.basename}}` (e.g. `dev`, `prod`).
- [applicationSet_Dev_PROD.yaml](applicationSet_Dev_PROD.yaml) — `list` generator variant. Explicitly enumerates `springlearning-dev` and `springlearning-prod` namespaces and points all of them at `springlearning/yaml-files` (the flat manifests, not the Kustomize overlays).
- [applicationSet_AWS_EKS.yaml](applicationSet_AWS_EKS.yaml) — placeholder for an EKS-targeted variant (currently empty).
- [appset-guestbook.yaml](appset-guestbook.yaml) — `list` generator pointing at the upstream `argoproj/argocd-example-apps` guestbook repo. Useful as a sanity check that Argo CD is wired up.
- [InitiateDeployment.sh](InitiateDeployment.sh) — deploy helper (currently empty).

## How it deploys

All `ApplicationSet`s reference `repoURL: https://github.com/Ravanan/2026-my-org-repo.git` on `main`. Each generated `Application` syncs with `automated: { prune: true, selfHeal: true }` — pushing to `main` triggers a sync.

## Conventions

- The two springlearning `ApplicationSet`s share the same `metadata.name: springlearning-appset` — only apply one at a time, otherwise the second `kubectl apply` will overwrite the first.
- Target namespaces are assumed to already exist (or be created by the manifests under [../springlearning/charts/templates/namespace.yaml](../springlearning/charts/templates/namespace.yaml)).

## Applying

```bash
kubectl apply -n argocd -f applicationSet.yaml
```
