# Airbyte v1 vs v2 Helm Chart Cross-Check

This document cross-checks all folders and components between `helm/airbyte-v1` and `helm/airbyte-v2` and confirms what was migrated for Blotout deployment.

## 1. Folder / structure comparison

### airbyte-v1 layout (umbrella chart)
- **Root:** `Chart.yaml`, `values.yaml`, `.helmignore`
- **charts/** (sub-charts, one per component):
  - `airbyte-bootloader/`
  - `common/` (shared helpers)
  - `connector-builder-server/`
  - `connector-rollout-worker/`
  - `cron/`
  - `keycloak/`
  - `keycloak-setup/`
  - `metrics/`
  - **`pod-sweeper/`** ← no equivalent in v2 (see below)
  - `server/`
  - `temporal/`
  - `temporal-ui/`
  - `webapp/`
  - `worker/`
  - `workload-api-server/`
  - `workload-launcher/`
- **templates/** (root-level only):
  - `NOTES.txt`, `_database.tpl`, `_enterprise.tpl`, `_helpers.tpl`, `_images.tpl`, `_keycloak.tpl`, `_logging.tpl`, `_storage.tpl`, `_temporal.tpl`
  - `airbyte-db.yaml`, `airbyte-yml-secret.yaml`, `env-configmap.yaml`, `gcs-log-creds-secret.yaml`, `minio.yaml`, `secret.yaml`, `serviceaccount.yaml`
  - `tests/`

### airbyte-v2 layout (single chart)
- **Root:** `Chart.yaml`, `values.yaml`, `.helmignore`, `Chart.lock`
- **templates/** (flat; no `charts/`):
  - Root: `NOTES.txt`, `_helpers.tpl`, `_images.tpl`, `airbyte-db.yaml`, `airbyte-yml-secret.yaml`, `env-configmap.yaml`, `gcs-log-creds-secret.yaml`, `minio.yaml`, `secret.yaml`, `serviceaccount.yaml`
  - **config/** – all config as partials: `_auth.tpl`, `_cluster.tpl`, `_common.tpl`, `_connector.tpl`, `_connectorBuilder.tpl`, `_connectorRollout.tpl`, `_cron.tpl`, `_customerio.tpl`, `_database.tpl`, `_datadog.tpl`, `_enterprise.tpl`, `_featureFlags.tpl`, `_java.tpl`, `_jobs.tpl`, `_keycloak.tpl`, `_logging.tpl`, `_metrics.tpl`, `_micronaut.tpl`, `_minio.tpl`, `_otel.tpl`, `_secretsManager.tpl`, `_server.tpl`, `_shopify.tpl`, `_storage.tpl`, `_temporal.tpl`, `_topology.tpl`, `_tracking.tpl`, `_webapp.tpl`, `_worker.tpl`, `_workloadApiServer.tpl`, `_workloadLauncher.tpl`, `_workloads.tpl`
  - One folder per component (no sub-charts):
    - `airbyte-bootloader/`
    - `airbyte-connector-builder-server/`
    - `airbyte-connector-rollout-worker/`
    - `airbyte-cron/`
    - `airbyte-featureflag-server/`
    - `airbyte-keycloak/`
    - `airbyte-keycloak-setup/`
    - `airbyte-metrics/`
    - `airbyte-server/`
    - `airbyte-temporal/`
    - `airbyte-temporal-ui/`
    - `airbyte-webapp/`
    - `airbyte-worker/`
    - `airbyte-workload-api-server/`
    - `airbyte-workload-launcher/`
  - `tests/`

## 2. Component mapping (v1 → v2)

| v1 component (chart or section) | v2 equivalent | Notes |
|---------------------------------|---------------|--------|
| `charts/airbyte-bootloader`      | `templates/airbyte-bootloader/` | ✓ |
| `charts/common`                  | `templates/config/` + `_helpers.tpl`, `_images.tpl` | Logic split into config partials |
| `charts/connector-builder-server` | `templates/airbyte-connector-builder-server/` | ✓ |
| `charts/connector-rollout-worker` | `templates/airbyte-connector-rollout-worker/` | ✓ |
| `charts/cron`                   | `templates/airbyte-cron/` | ✓ |
| `charts/keycloak`               | `templates/airbyte-keycloak/` | ✓ |
| `charts/keycloak-setup`         | `templates/airbyte-keycloak-setup/` | ✓ |
| `charts/metrics`                | `templates/airbyte-metrics/` | ✓ |
| **charts/pod-sweeper**          | **None** | v2 chart does not include pod-sweeper (Airbyte 2.0 design) |
| `charts/server`                 | `templates/airbyte-server/` | ✓ |
| `charts/temporal`               | `templates/airbyte-temporal/` | ✓ |
| `charts/temporal-ui`            | `templates/airbyte-temporal-ui/` | ✓ |
| `charts/webapp`                 | `templates/airbyte-webapp/` | ✓ |
| `charts/worker`                 | `templates/airbyte-worker/` | ✓ |
| `charts/workload-api-server`    | `templates/airbyte-workload-api-server/` | ✓ |
| `charts/workload-launcher`      | `templates/airbyte-workload-launcher/` | ✓ |
| featureflag-server (values only in v1) | `templates/airbyte-featureflag-server/` | ✓ v2 has dedicated templates |
| Root `templates/*.yaml` / `*.tpl` | Same names under `templates/` or `templates/config/` | ✓ |

## 3. Values.yaml top-level keys

| v1 key                    | v2 key                 | Migrated / notes |
|---------------------------|------------------------|------------------|
| `global`                  | `global`               | ✓ (Blotout settings applied) |
| `nameOverride`            | `nameOverride`        | ✓ |
| `fullnameOverride`        | `fullnameOverride`    | ✓ |
| `serviceAccount`          | `serviceAccount`      | ✓ |
| `version`                 | `version`             | ✓ |
| `webapp`                  | `webapp`              | ✓ (ingress enabled, nginx) |
| `pod-sweeper`             | —                     | No pod-sweeper in v2 |
| `server`                  | `server`              | ✓ (resources, env_vars BLOTOUT_*) |
| `worker`                  | `worker`              | ✓ (resources) |
| `workload-launcher`       | `workloadLauncher`    | ✓ (resources) |
| `connector-rollout-worker`| `connectorRolloutWorker` | ✓ |
| `metrics`                 | `metrics`             | ✓ |
| `airbyte-bootloader`      | `airbyteBootloader`   | ✓ |
| `temporal`                | `temporal`            | ✓ |
| `temporal-ui`             | `temporalUi`          | ✓ |
| `postgresql`              | `postgresql`          | ✓ (disabled for external DB) |
| `externalDatabase`        | —                     | v2 uses `global.database` only ✓ |
| `minio`                   | `minio`               | ✓ (disabled for S3) |
| `cron`                    | `cron`                | ✓ |
| `connector-builder-server`| `connectorBuilderServer` | ✓ |
| `keycloak`                | `keycloak`            | ✓ |
| `keycloak-setup`          | `keycloakSetup`       | ✓ |
| `workload-api-server`     | `workloadApiServer`   | ✓ (resources) |
| `featureflag-server`      | `featureflagServer`   | ✓ |
| `testWebapp`              | `testWebapp`          | ✓ |

## 4. Blotout-specific customizations (where they live)

| Customization | v1 location | v2 location |
|---------------|-------------|-------------|
| Secret name `airbyte-v1-airbyte-secrets` | `values.yaml` (enterprise, auth, database, storage) | `values.yaml` (global.database.secretName, global.storage.secretName, global.enterprise.secretName, auth.instanceAdmin.secretName) ✓ |
| S3 buckets `b-multitenantdev-dev-airbyte-v1-logs` | `values.yaml` global.storage.bucket | `values.yaml` global.storage.bucket (log, state, workloadOutput, activityPayload) ✓ |
| S3 storage + region/us-east-1 | `values.yaml` global.storage | `values.yaml` global.storage (type: s3, s3.region, etc.) ✓ |
| External DB (host, port, user, database name) | `values.yaml` global.database | `values.yaml` global.database ✓ |
| Image pull secret `regcred` | `values.yaml` global.imagePullSecrets | `values.yaml` global.imagePullSecrets ✓ |
| Job/resources (CPU/memory limits and requests) | `values.yaml` + env-configmap (resource_cpu_limit etc.) | `values.yaml` global.workloads.resources.mainContainer + server/worker/workloadLauncher/workloadApiServer.resources ✓ |
| BLOTOUT_AUTH_ENDPOINT, BLOTOUT_BASE_URL | `values.yaml` server.env_vars + (commented) env-configmap / server deployment | `values.yaml` server.env_vars ✓ |
| AWS keys (for jobs/configmap in v1) | env-configmap from global.aws_access_key/aws_secret_key | v2 uses storage secret for S3; global.env_vars has SECRET_PERSISTENCE, S3_PATH_STYLE_ACCESS where needed ✓ |
| Ingress (nginx, enabled, hosts) | webapp.ingress in values | webapp.ingress in values + ingress template fix (webapp.ingress.*) ✓ |
| PostgreSQL disabled, Minio disabled | values | values (postgresql.enabled: false, minio.enabled: false) ✓ |

## 5. What was not carried over (by design)

- **pod-sweeper:** Present in v1 as a sub-chart; not part of the v2 chart. No migration.
- **v1 root `_database.tpl`, `_enterprise.tpl`, etc.:** Replaced by `templates/config/_*.tpl` in v2; behavior is covered by config partials and values we set.

## 6. Verification

- `helm template` on `helm/airbyte-v2` runs successfully with the current values.
- All v2 components that have a v1 counterpart are present under `templates/`; Blotout-specific values are set in `helm/airbyte-v2/values.yaml`.

---

**Summary:** All folders and components present in airbyte-v2 that correspond to airbyte-v1 have been cross-checked. Blotout customizations from v1 are applied in v2 values and (where needed) via the fixed webapp ingress template. The only v1 component with no v2 equivalent is **pod-sweeper**, which is absent from the v2 chart by design.
