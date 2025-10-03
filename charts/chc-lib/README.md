# chc-lib

![Version: 0.44.25](https://img.shields.io/badge/Version-0.44.25-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

Library chart to provide reusable functions and templates to compose application charts with.

**Homepage:** <https://github.com/aoksys-platform-engineering/helm-charts/tree/main/charts/chc-lib>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Oliver Geyer | <N/A> | <https://www.aok-systems.de/startseite.html> |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | common | 2.31.4 |

# Usage
Include chc-lib as a dependency in your application chart to use it,
because it cannot be installed or templated on its own:

```bash
$ helm template --generate-name chc-lib
Error: library charts are not installable
```

Add the following `dependencies` to your charts `Chart.yaml` to use the chc-lib:

```yaml
# Chart.yaml of your application chart
---
...
dependencies:
  - name: chc-lib
    version: 0.44.25
    repository: https://aoksys-platform-engineering.github.io/helm-charts
    # The "import-values" stanza is mandatory to not fail during templating due to missing default values.
    # Other predefined values are optional.
    import-values:
      - defaults
```

# Values
This section explains how to use the `values.yaml` to configure the provided templates.

## Dynamic values
When `Goes through tpl`, `Values go through tpl` (or similar) is mentioned in the description of a value
you can use helms templating syntax to dynamically compute the value when templates are rendered.

You need to make sure that computed values are quoted to be rendered correctly:

```yaml
# Example values
---
...
commonLabels:
  example: "{{ .Release.Namespace }}"

service:
  ...
  ports:
  "{{ .Release.Name }}-https":
      port: 443
      targetPort: 8443
      nodePort: 10443
      porotocol: TCP
...
```

> NOTE
>
> You cannot use more complex expressions like `{{ .Values.service.ports[0].name }}` or
> `{{ include "common.names.fullname" . }}` to compute values because expressions like that will result in templating errors.

Many templates use `tpl` for their values to take advantage of helms templating engine.
Use them whenever possible to minimize the number of values files needed to deploy to different stages and environments.

## Common
Values that are used in almost all templates and can be set at `.Values.<Value>`.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| nameOverride | string | `""` | Used to override the base name for all resources. |
| fullnameOverride | string | `""` | Used to override the full name for all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. Values go through tpl. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. Values go through tpl. |
| imageRegistry | string | `""` | Default imageRegistry to use when no other registry is specified for a container. |

## Configs
Values that can be set at `.Values.configs.<Value>`. These values are used in the configMaps template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of configMaps. |
| labels | object | `{}` | Labels to add to all configMaps in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to all configMaps in addition to `commonAnnotations`. Values go through tpl. |
| items | object | `{}` | Dict containing key/value pairs of configMaps to create. Follows the `Secret and config items` input scheme. See [Secret and config items](#secret-and-config-items) in README for more. |

## Secrets
Values that can be set at `.Values.secrets.<Value>`. These values are used in the secrets template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of secrets. |
| labels | object | `{}` | Labels to add to all secrets in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to all secrets in addition to `commonAnnotations`. Values go through tpl. |
| items | object | `{}` | Dict containing key/value pairs of secrets to create. Follows the `Secret and config items` input scheme. See [Secret and config items](#secret-and-config-items) in README for more. |

## Deployment
Values that can be set at `.Values.deployment.<Value>`. These values are used in the deployment template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the deployment. Mutually exclusive with `.Values.statefulset.create=true`. |
| labels | object | `{}` | Labels to add to the deployment in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the deployment in addition to `commonAnnotations`. Values go through tpl. |
| replicas | int | `1` | Number of pods to create. |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy for pods. |
| revisionHistoryLimit | int | `10` | Number of ReplicaSet revisions to keep. |
| pods | object | `{}` | Values to configure the pods managed by the deployment. Follows the `PodTemplate` input scheme. See [PodTemplate](#podtemplate) in README for more. |

## StatefulSet
Values that can be set at `.Values.statefulset.<Value>` to configure the statefulset template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of a statefulset. Mutually exclusive with `.Values.deployment.create=true`. |
| minReadySeconds | int | `0` | Minimum number of seconds for which a pod should be ready without any of its container crashing until it is considered healthy. |
| podManagementPolicy | string | `"OrderedReady"` | Policy to control how pods are created during initial scale up, when replacing pods on nodes, or when scaling down. Can be `OrderedReady` or `Parallel`. |
| replicas | int | `1` | Number of pods to create. |
| revisionHistoryLimit | int | `10` | Maximum number of revisions that will be maintained in the StatefulSet's revision history. |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy for pods. |
| volumeClaimTemplates | list | `[]` | A list of storage claims that are created and attached to the statefulset automatically. Useful to dynamically provision PVCs that are mapped to each pod controlled by the statefulset. It takes precedence over volumes defined in the PodTemplate, if a volume and volumeClaimTemplate have the same name. Should be used with caution because volumes managed by a volumeClaimTemplate cannot be resized dynamically after their creation. Values go through tpl. |
| persistentVolumeClaimRetentionPolicy | object | `{"whenDeleted":"Delete","whenScaled":"Delete"}` | Policy to manage the lifecycle of PVCs created from volumeClaimTemplates. By default, all persistent volume claims are created as needed and deleted when the statefulset is uninstalled. Very handy to automatically delete PVCs and assiciated volumes after pod autoscaling. |
| persistentVolumeClaimRetentionPolicy.whenDeleted | string | `"Delete"` | WhenDeleted specifies what happens to PVCs created from volumeClaimTemplates when the statefulset is deleted. Can be `Retain` or `Delete`. |
| persistentVolumeClaimRetentionPolicy.whenScaled | string | `"Delete"` | WhenScaled specifies what happens to PVCs created from volumeClaimTemplates when pods managed by the statefulset are scaled down. Can be `Retain` or `Delete`. |
| pods | object | `{}` | Values to configure the pods managed by the statefulset. Follows the `PodTemplate` input scheme. See [PodTemplate](#podtemplate) in README for more. |

## Horizontal Pod Autoscaler (HPA)
Values that can be set at `.Values.hpa.<Value>` to configure the hpa template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of the hpa. |
| labels | object | `{}` | Labels to add to the hpa in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the hpa in addition to `commonAnnotations`. Values go through tpl. |
| minReplicas | int | `1` | The lower limit for the number of pods to which the hpa can scale down.  |
| maxReplicas | int | `3` | The upper limit for the number of pods that can be set by the hpa. Cannot be smaller than `minReplicas`. |
| targetCPUUtilizationPercentage | int | `70` | The target average CPU utilization (represented as a percentage of requested CPU) over all the pods. |
| targetMemoryUtilizationPercentage | string | `nil` | The target average memory utilization (represented as a percentage of requested memory) over all the pods. |

## Service
Values that can be set at `.Values.service.<Value>` to configure the service template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of a service. |
| labels | object | `{}` | Labels to add to the service in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the service in addition to `commonAnnotations`. Values go through tpl. |
| type | string | `"ClusterIP"` | Type of the service to create. |
| sessionAffinity | string | `"None"` | Session affinity to control how requests are routed. Can be `ClientIP` or `None`. |
| sessionAffinityConfig | string | `nil` | Session affinity configs to be set in addition to `sessionAffinity`. |
| ports | object | `{}` | Ports for the service. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more. |

## Ingress
Values that can be set at `.Values.ingress.<Value>` to configure the ingress template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of an ingress. |
| labels | object | `{}` | Labels to add to the ingress in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the ingress in addition to `commonLabels`. Values go through tpl. |
| className | string | `""` | Name of the ingress class to use. Will be ommitted if empty. |
| rules | list | `[]` | List of rules for the ingress. Values go through tpl. See https://kubernetes.io/docs/concepts/services-networking/ingress for more. |
| tls | list | `[]` | List of TLS hosts to serve using the ingress. Values go through tpl. See https://kubernetes.io/docs/concepts/services-networking/ingress for more. |

## ServiceAccount
Values that can be set at `.Values.serviceAccount.<Value>` to configure the serviceaccount template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable creation of the serviceaccount. |
| name | string | `""` | Name of the serviceaccount to create. Will be generated, if empty. |
| labels | object | `{}` | Labels to add to the serviceaccount in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the serviceaccount in addition to `commonAnnotations`. Values go through tpl. |
| automountServiceAccountToken | bool | `false` | Toggle to enable/disable the `automountServiceAccountToken` feature. Mounting the serviceaccount token is only necessary if your app calls the K8s API. |

## Role-Based Access Control (RBAC)
Values that can be set at `.Values.rbac.<Value>` to configure the role and rolebinding templates.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable creation of RBAC resources. |
| namespaceOverride | string | `""` | Namespace to create RBAC resources in. If empty or unset, `{{ .Release.Namespace }}` is used. |
| role.labels | object | `{}` | Labels to add to the role in addition to `commonLabels`. Values go through tpl. |
| role.annotations | object | `{}` | Annotations to add to the role in addition to `commonAnnotations`. Values go through tpl. |
| role.rules | list | `[]` | Rules to add to the role. Values go through tpl. |
| roleBinding.labels | object | `{}` | Labels to add to the rolebinding in addition to `commonLabels`. Values go through tpl. |
| roleBinding.annotations | object | `{}` | Annotations to add to the rolebinding in addition to `commonAnnotations`. Values go through tpl. |

## Pod Disruption Budget (PDB)
Values that can be set at `.Values.pdb.<Value>` to configure the pdb template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable creation of the pdb. |
| labels | object | `{}` | Labels to add to the pdb in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the pdb in addition to `commonAnnotations`. Values go through tpl. |
| minAvailable | int | `1` | An eviction is allowed if at least `minAvailable` pods will still be available after the eviction. |
| maxUnavailable | int | `1` | An eviction is allowed if at most `maxUnavailable` pods are unavailable after the eviction. This only takes effect if `minAvailable` is set to nil (~). |

## Job
Values that can be set at `.Values.job.<Value>` to configure the job template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of the job. |
| generateName | bool | `false` | Toggle to generate a suffix for `metadata.name` everytime the job is deployed. |
| labels | object | `{}` | Labels to add to the job in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the job in addition to `commonLabels`. Values go through tpl. |
| spec | object | `{}` | Values to configure the job with. Follows the `JobTemplate` input scheme. See [JobTemplate](#jobtemplate) in README for more. |

## CronJob
Values that can be set at `.Values.cronjob.<Value>` to configure the cronjob template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of the cronjob. |
| labels | object | `{}` | Labels to add to the cronjob in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the cronjob in addition to `commonAnnotations`. Values go through tpl. |
| concurrencyPolicy | string | `"Forbid"` | Specifies how to treat concurrent executions of a Job. Valid values are `Allow`, `Forbid` and `Replace`. |
| successfulJobsHistoryLimit | int | `1` | The number of successful finished jobs to retain. Value must be non-negative integer. |
| failedJobsHistoryLimit | int | `3` | The number of failed finished jobs to retain. Value must be non-negative integer. |
| schedule | string | `"@daily"` | The schedule to spawn jobs in Cron format, see https://en.wikipedia.org/wiki/Cron. |
| timeZone | string | `"Europe/Berlin"` | Time zone (TZ identifier) for the schedule. See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for more. |
| startingDeadlineSeconds | int | `180` | Deadline in seconds for starting the job if it misses scheduled time for any reason. Missed jobs executions will be counted as failed ones. Will be omitted, if set to nil ("~"). |
| suspend | bool | `false` | This flag tells the controller to suspend subsequent executions. |
| jobs | object | `{}` | Values to configure the jobs managed by the cronjob. Follows the `JobTemplate` input scheme. See [JobTemplate](#jobtemplate) in README for more. |

## Cert-Manager
Values that can be set at `.Values.certManager.<Value>` to enable the usage of related custom resources.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| enabled | bool | `false` | Toggle to enable/disable the creation of cert-manager related custom resources. Should only be set to `true` if the corresponding custom resource definitions are installed in your cluster. |

### Certificates
Values that can be set at `.Values.certManager.certificates.<Value>`. These values are used in the certificates template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of certificate resources. |
| labels | object | `{}` | Labels to add to all certificates in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to all certificates in addition to `commonAnnotations`. Values go through tpl. |
| secretLabels | object | `{}` | Labels to add to all secrets created from certificates in addition to `commonLabels`. Values go through tpl. |
| secretAnnotations | object | `{}` | Annotations to add to all secrets created from certificates in addition to `commonAnnotations`. Values go through tpl. |
| issuerKind | string | `"ClusterIssuer"` | Issuer kind to use for all certificates. Can be overwritten in each certificate. |
| issuerName | string | `"ca-issuer"` | Issuer name to use for all certificates. Can be overwritten in each certificate. |
| duration | string | `"720h0m0s"` | Duration of validity for all certificates. Can be overwritten in each certificate. |
| renewBefore | string | `"480h0m0s"` | When to renew certificates before they expire. Can be overwritten in each certificate. |
| commonName | string | `"{{ .Release.Name }}"` | Common name to use for all certificates. Goes through tpl. Can be overwritten in each certificate. |
| dnsNames | list | `["{{ .Release.Name }}","{{ .Release.Name }}.{{ .Release.Namespace }}","{{ .Release.Name }}.{{ .Release.Namespace }}.svc.cluster.local"]` | List of dnsNames to use for all certificates. Goes through tpl. Can be overwritten in each certificate. |
| privateKey | object | `{"algorithm":"RSA","encoding":"PKCS1","size":2048}` | Spec for how to create the the private key for all certificates. Can be overwritten in each certificate. |
| items | object | `{}` | Dict containing key/value pairs of certificates to create. Follows the `Certificate items` input scheme. See [Certificate items](#certificate-items) in README for more. |

## External-Secrets Operator
Values that can be set at `.Values.externalSecretsOperator.<Value>` to enable the usage of related custom resources.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| enabled | bool | `false` | Toggle to enable/disable the creation of external-secrets operator related custom resources. Should only be set to `true` if the corresponding custom resource definitions are installed in your cluster. |

### ExternalSecrets
Values that can be set at `.Values.externalSecretsOperator.externalSecrets.<Value>`. These values are used in the externalsecrets template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of external-secret resources. |
| labels | object | `{}` | Labels to add to all externalsecrets. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to all externalsecrets. Values go through tpl. |
| secretLabels | object | `{}` | Labels to add to all secrets created from externalsecrets. Values go through tpl. |
| secretAnnotations | object | `{}` | Annotations to add to all secrets created from externalsecrets. Values go through tpl. |
| secretType | string | `"Opaque"` | Type of secret to create. Can be overwritten in each externalsecret. |
| secretStoreName | string | `"default"` | Name of the secret store to use. Can be overwritten in each externalsecret. |
| secretStoreKind | string | `"ClusterSecretStore"` | Kind of secret store to use. Can be overwritten in each externalsecret. |
| refreshPolicy | string | `"Periodic"` | Refresh policy for externalsecrets. Can be overwritten in each externalsecret. |
| refreshInterval | string | `"1h"` | Refresh intervall for all externalsecrets. Can be overwritten in each externalsecret. |
| creationPolicy | string | `"Owner"` | Creation policy to configure the behaviour of owenership for created secrets. Can be overwritten in each externalsecret. |
| deletionPolicy | string | `"Merge"` | Deletion policy to configure what happens to secrets when data fields are deleted from the provider (e.g., Vault, AWS SecretsManager). Can be overwritten in each externalsecret. |
| basePath | string | `""` | Base path to prepend `providerSecretName` in `remoteRef` items with. Useful if you have a common path for all externalSecrets in your backend. |
| decodingStrategy | string | `"None"` | Decoding strategy to use for all externalsecrets in the `remoteRef` fields. Can be overwritten in each externalsecret. |
| conversionStrategy | string | `"Default"` | Conversion strategy to use for all externalsecrets in the `remoteRef` fields. Can be overwritten in each externalsecret. |
| metadataPolicy | string | `"None"` | Metadata policy to use for all externalsecrets in the `remoteRef` fields. Can be overwritten in each externalsecret. |
| items | object | `{}` | Dict containing key/value pairs of externalsecrets to create. See [ExternalSecret items](#externalsecret-items) in README for more. |

## Prometheus-Operator
Values that can be set at `.Values.prometheusOperator.<Value>` to enable the usage of related custom resources.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| enabled | bool | `false` | Toggle to enable/disable the creation of prometheus-operator related custom resources. Should only be set to `true` if the corresponding custom resource definitions are installed in your cluster. |

### PodMonitor
Values that can be set under `.Values.prometheusOperator.podMonitor.<Value>` to configure the podMonitor template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `false` | Toggle to enable/disable the creation of the podMonitor resource. |
| namespaceOverride | string | `""` | Namespace to create the podMonitor resource in. If empty or unset, `{{ .Release.Namespace }}` is used. |
| labels | object | `{}` | Labels to add to the podMonitor in addition to `commonLabels`. Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the podMonitor in addition to `commonAnnotations`. Values go through tpl. |
| podMetricsEndpoints | object | `{}` | Defines a list of endpoints serving metrics to be scraped by prometheus. See https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMetricsEndpoint for all available options. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more. |

## Extra manifests
The values for `extraManifests` are a list of arbitrary kubernetes YAML manifests to use when there is no dedicated library template (yet).
It is meant to be used as a fallback to not slow down the development and deployment of new services before a new template is added to the `chc-lib`.

You simply provide the YAML of kubernetes manifests to deploy as value for the `extraManifests` list. All values go through tpl.

These example values ...

```yaml
---
extraManifests:
  - apiVersion: v1
    kind: Namespace
    metadata:
      name: "{{ .Release.Name }}"

  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "{{ .Release.Name }}-config"
      namespace: "{{ .Release.Namespace }}"
    data:
      app.env: production
      log.level: info
```

... generate this YAML output:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: example
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-config
  namespace: default
data:
  app.env: production
  log.level: info
```

## Custom input schemes
Because the chc-lib is a library chart, most values have sane defaults or are omitted from the templated output if the user doesn't configure them explicitly.

Some parts of the values use more complex data types than strings, integers or booleans and require additional knowledge to be used properly.
This section describes those data types ("input schemes") and provides examples on how to configure them and what the templated output looks like.
Note that some values depend on metadata of the release, like `{{ .Release.Name }}` and `{{ .Release.Namespace }}`, and cannot be resolved in those examples.
They are shown as `<placeholders>`.

The following keywords are used to describe how values behave when a chart is rendered:

* `mandatory`: If a value is "mandatory", there is no default value set and the user has to provide a valid, non empty value for it. Otherwise, the chart will produce an error when templates are rendered.
* `omitted`: If a value is "omitted", there is no default value set and the field will only be part of the templated output if the user explicitly sets a non empty value for it.
* `computed`: If a value is "computed", the chart generates it in some way and the value may not be overwritten by a user at this path.
* `helm default labels`: When this default is set, the user doesn't have to provide a value, but provided values are merged with a set of always rendered, recommended default labels for kubernetes objects (https://helm.sh/docs/chart_best_practices/labels/#standard-labels).

## JobTemplate
This section explains which values can be set when the `JobTemplate` input scheme is used.

| Value                   | Type   | Default             | Description                                                                                                                                                                    |
|-------------------------|--------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| labels                  | dict   | helm default labels | Labels to add to jobs in addition to `commonLabels`. Values go through tpl.                                                                                                    |
| annotations             | dict   | omitted             | Annotations to add to jobs in addition to `commonLabels`. Values go through tpl.                                                                                               |
| activeDeadlineSeconds   | int    | 600                 | Specifies the duration in seconds relative to the startTime that the job may be continuously active before the system tries to terminate it. Value must be a positive integer. |
| backoffLimit            | int    | 3                   | Specifies the number of retries before marking this job as failed.                                                                                                             |
| backoffLimitPerIndex    | int    | omitted             | Specifies the limit for the number of retries within an index before marking this index as failed. Only takes effect if `completionMode=Indexed`.                              |
| completionMode          | string | NonIndexed          | CompletionMode specifies how Pod completions are tracked. Can be `NonIndexed` or `Indexed`.                                                                                    |
| completions             | int    | 1                   | Specifies the desired number of successfully finished pods the job should be run with.                                                                                         |
| parallelism             | int    | 1                   | Specifies the maximum desired number of pods the job should run at any given time. This value is bound to the value for `completions`.                                         |
| suspend                 | bool   | false               | Specifies whether the Job controller should create Pods or not. This can be set `false` to pause job execution.                                                                |
| ttlSecondsAfterFinished | int    | 86400               | This limits the lifetime of a Job that has finished execution (either Complete or Failed). After `ttlSecondsAfterFinished` have passed, pods will be cleaned up automatically. |
| pods                    | dict   | {}                  | All values eligible to configure pods managed by the job. Follows the `PodTemplate` input scheme. See [PodTemplate](#podtemplate) in README for more.                          |

You can use any of the above listed values when configuring a job. Note that if you don't set any values, the defaults from `chc-lib` are used.

## PodTemplate
This section explains which values can be set when the `PodTemplate` input scheme is used.

| Value                         | Type           | Default             | Description                                                                                                                                                                     |
|-------------------------------|----------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| labels                        | dict           | helm default labels | Labels to add to pods in addition to `commonLabels`. Values go through tpl.                                                                                                     |
| annotations                   | dict           | omitted             | Annotations to add to pods in addition to `commonLabels`. Values go through tpl.                                                                                                |
| restartPolicy                 | string         | Always              | Policy to manage restart behaviour for all containers in pods.                                                                                                                  |
| securityContext               | dict or string | "default" preset    | Security context for pods. Can be a preset name (string) or a dict. See [PodSecurityContext](#podsecuritycontext) in README for more.                                           |
| serviceAccountName            | string         | computed            | Name of the serviceAccount to use. Computed from `.Values.serviceAccount` settings.                                                                                             |
| imagePullSecrets              | list           | omitted             | List of secrets to pull container images from container registries with.                                                                                                        |
| affinity.podAffinity          | dict or string | omitted             | Affinity for pod scheduling. Can be a preset name (string) or a dict. See [Affinities](#affinities) in README for more.                                                         |
| affinity.podAntiAffinity      | dict or string | omitted             | Anti affinity for pod scheduling. Can be a preset name (string) or a dict. See [Affinities](#affinities) in README for more.                                                    |
| affinity.nodeAffinity         | dict           | omitted             | Node affinity for pod scheduling. Can only be defined as dict, because no preset exists. Values go thorugh tpl.                                                                 |
| tolerations                   | list           | omitted             | Tolerations for pod scheduling.                                                                                                                                                 |
| nodeSelector                  | dict           | omitted             | Node selector for pod scheduling. Simpler to use than `affinity.nodeAffinity`, but limited to simple label selectors.                                                           |
| hostAliases                   | list           | omitted             | List of host aliases to inject into the pod.                                                                                                                                    |
| priorityClassName             | string         | omitted             | Name of a priorityClass to use.                                                                                                                                                 |
| hostNetwork                   | bool           | omitted             | Toggle to start pods in hostNetwork mode.                                                                                                                                       |
| dnsPolicy                     | string         | omitted             | DNS policy to use. Should probably be set to `ClusterFirstWithHostNet`, if `hostNetwork=true`.                                                                                  |
| terminationGracePeriodSeconds | int            | omitted             | Seconds to wait for graceful termination of the pod, when a SIGTERM/SIGKILL is send by kubernetes.                                                                              |
| volumes                       | dict           | omitted             | Volumes to mount into pods. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more.                                                      |
| containers                    | dict           | {}                  | Containers to inject into pods. Follows the `ContainerSpec` input scheme. See [ContainerSpec](#containerspec) in README for more.                                               |
| initContainers                | dict           | omitted             | Containers to inject into pods. Follows the `ContainerSpec` input scheme plus a mandatory `weight` value for odering. See [InitContainers](#initcontainers) in README for more. |

You can use any of the above listed values when configuring a pod. Note that if you don't set any value, the `chc-lib` defaults are used.

### PodSecurityContext
When configuring the `securityContext` in a `PodTemplate`, you can provide values either as string or dict.

The chart behaves differently depending on the type of values provided:
- Dict value: The value is used as-is without further processing. An empty dict (`{}`) is valid input, too.
- String value: The chart checks if the string matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is returned that lists all presets available.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Generated YAML block</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>default</td>
      <td>
        <pre><code class="language-yaml">runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault</code></pre>
      </td>
    </tr>
  </tbody>
</table>

### Affinities
When configuring `affinity.podAffinity` or `affinity.podAntiAffinity` in a `PodTemplate`, you can provide values either as string or dict.

The chart behaves differently depending on the values provided:
- Dict value: The value is used as-is without further processing. An empty dict (`{}`) is valid input, too.
- String value: The chart checks if the string matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is returned that lists all presets available.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Generated YAML block</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>soft</td>
      <td>
        <pre><code class="language-yaml">preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      topologyKey: kubernetes.io/hostname
      labelSelector:
        matchLabels:
          - &lt;computed&gt;</code></pre>
      </td>
    </tr>
    <tr>
      <td>hard</td>
      <td>
        <pre><code class="language-yaml">requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: kubernetes.io/hostname
    labelSelector:
      matchLabels:
        - &lt;computed&gt;</code></pre>
      </td>
    </tr>
  </tbody>
</table>

> NOTE
>
> The preset names and generated YAML output for `affinity.podAffinity` and `affinity.podAntiAffinity` are identical, because they follow the same k8s spec.
> K8s only checks if values are indented under `podAffinity` or `podAntiAffinity` to decide which scheduling actions to perform.

## ListFromDict
This scheme accepts values as dict for proper merging when layering values files.
The `chc-lib` converts the dict items into an unordered list when rendering a template.
It is used to compute all kinds of values like `volumes`, `volumeMounts`, `ports`, `ENVs` and more.
It is also used in various specs and templates like the `JobTemplate`, `PodTemplate`, `ContainerSpec` and others.

When a value follows the `ListFromDict` scheme, the `name` field for each item of the generated list is populated from its key in the dict.
The values can be provided in free-form, are merged and indented (to generate a properly formatted list) and all items go through tpl.

These example values ...

```yaml
---
...
deployment:
  ...
  pods:
    ...
    volumes:
      # Keys and values are templated
      "{{ .Release.Name }}-configs":
        configMap:
          name: "{{ .Release.Name }}"
          items:
            - key: log_level
              path: log_level.conf
     
      cache:
        emptyDir:
          sizeLimit: 500Mi

    containers:
      example:
        env:
          "{{ .Release.Name }}-configs":
            valueFrom:
              configMapKeyRef:
                name: special-config
                key: special.how

          LOG_LEVEL:
            value: DEBUG

        volumeMounts:
          # Keys and values are templated
          "{{ .Release.Name }}-configs":
            mountPath: /etc/config
        
          cache:
            mountPath: /cache

        ports:
          "{{ .Release.Name }}-https":
            containerPort: 8443
            porotocol: TCP
```

... generate this YAML output:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      volumes:
        - name: example-configs
          configMap:
            name: example
            items:
              - key: log_level
                path: log_level.conf
       
        - name: cache
          emptyDir:
            sizeLimit: 500Mi

      containers:
        - name: example
          ...
          env:
            - name: LOG_LEVEL
              value: DEBUG
            - name: example-configs
              valueFrom:
                configMapKeyRef:
                  name: special-config
                  key: special.how

          volumeMounts:
            - name: example-configs
              mountPath: /etc/config
          
            - name: cache
              mountPath: /cache

          ports:
            - name: example-https
              containerPort: 8443
              porotocol: TCP
          ...
```

> NOTE
>
> Some input schemes like `JobTemplate`, `PodTemplate`, `ContainerSpec` and others technically follow the `ListFromDict` pattern, but there is an important difference:
>
> * In a `JobTemplate`, `PodTemplate`, `ContainerSpec` etc. only a predefined list of keys will be picked up and processed by the template.
> * In a `ListFromDict` input, arbitrary keys and values are taken as-is, converted into a list, indented, and processed through tpl.

## ContainerSpec
This section explains which values can be set when the "ContainerSpec" input scheme is used.

| Value           | Type           | Default          | Description                                                                                                                                                                                                         |
|-----------------|----------------|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name            | string         | computed         | Value for the `name` field of the container. This is generated from the key of the dict item.                                                                                                                       |
| image           | dict           | mandatory        | Container image to use. Follows the `Images` input scheme. See [Images](#images) in README for more.                                                                                                                |
| command         | list           | omitted          | List of commands to use as ENTRYPOINT for the container. If not specified, the ENTRYPOINT from the container image is used. Values go through tpl.                                                                  |
| args            | list           | omitted          | List of argument to provide for the ENTRYPOINT. Values go through tpl.                                                                                                                                              |
| securityContext | dict or string | "default" preset | Security context for the container. Can be a preset name (string) or a dict. See [ContainerSecurityContext](#containersecuritycontext) in README for more.                                                          |
| restartPolicy   | string         | omitted          | RestartPolicy defines the restart behavior of individual containers in a pod. This field may only be set for init containers. For non-init containers, the restart behavior is defined by the Pod's restart policy. |
| resources       | dict or string | "xsmall" preset  | Resources for the container. Can be a preset name (string) or a dict. See [Resources](#resources) in README for more.                                                                                               |
| volumeMounts    | dict           | omitted          | Volumes to mount in the container. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more.                                                                                   |
| env             | dict           | omitted          | ENVs to set for the container. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more.                                                                                       |
| ports           | dict           | {}               | Ports for the container. Follows the `ListFromDict` input scheme. See [ListFromDict](#listfromdict) in README for more.                                                                                             |
| startupProbe    | dict           | omitted          | StartupProbe indicates that the Pod has successfully initialized. If specified, no other probes are executed until this completes successfully.                                                                     |
| livenessProbe   | dict           | omitted          | Periodic probe of container liveness. Container will be restarted if the probe fails.                                                                                                                               |
| readinessProbe  | dict           | omitted          | Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails.                                                                                                 |

You can use all of the above values to configure a container. This is true for initContainers, too.

### Images
When configuring the `image` for a container, you have to provide values in a specific way to ensure they are picked up and processed correctly.

Provide the following values to configure the image of a container:

| Value      | Type   | Default                                   | Description                                                                                                                                                                         |
|------------|--------|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| registry   | string | omitted                                   | Registry to pull the container image from. If unset, the value of `imageRegistry` is used. If `imageRegistry` is empty, the default container registry in your k8s cluster is used. |
| repository | string | mandatory                                 | Repository in the registry to pull the container image from.                                                                                                                        |
| tag        | string | `{{ .Chart.AppVersion }}` | Tag of the container image to pull.                                                                                                                                                 |
| digest     | string | omitted                                   | Image digest to use when pulling the container.                                                                                                                                     |
| pullPolicy | string | omitted                                   | Policy when images are pulled from the registry. Can be `Always` or `IfNotPresent`.                                                                                                 |

These example values ...

```yaml
---
...
imageRegistry: 111111111111.dkr.ecr.eu-central-1.amazonaws.com
...
deployment:
  ...
  pods:
    ...
    initContainers:
      hello-world:
        weight: 1
        image:
          registry: docker.io
          repository: hello-world
          tag: nanoserver-ltsc2025
          digest: sha256:1b11ba01aabdfa656e408bc1cb461a4d2f593056c37cf59240d259e3958202f9
        ...

    containers:
      example:
        image:
          repository: my/example
          tag: 1.0.0
          pullPolicy: Always
        ...
```

... generate this YAML output:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      initContainers:
        - name: hello-world
          image: docker.io/hello-world:nanoserver-ltsc2025@sha256:1b11ba01aabdfa656e408bc1cb461a4d2f593056c37cf59240d259e3958202f9
          ...

      containers:
        - name: example
          image: 111111111111.dkr.ecr.eu-central-1.amazonaws.com/my/example:1.0.0
          imagePullPolicy: Always
          ...
```

### ContainerSecurityContext
When configuring the `securityContext` for a container, you can provide values either as string or dict.

The chart behaves differently depending on the type of values provided:
- Dict value: The value is used as-is without further processing. An empty dict (`{}`) is valid input, too.
- String value: The chart checks if the string matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is returned that lists all presets available.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Generated YAML block</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>default</td>
      <td>
        <pre><code class="language-yaml">privileged: false
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL</code></pre>
      </td>
    </tr>
  </tbody>
</table>

### Resources
When configuring the `resources` for a container, you can provide values either as string or dict.

The chart behaves differently depending on the type of values provided:
- Dict value: The value is used as-is without further processing. An empty dict (`{}`) is valid input, too.
- String value: The chart checks if the string matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is returned that lists all presets available.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Generated YAML block</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>xsmall</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 10m
  memory: 64Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
    <tr>
      <td>small</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 250m
  memory: 384Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
    <tr>
      <td>medium</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 500m
  memory: 768Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
    <tr>
      <td>large</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 1000m
  memory: 1536Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
    <tr>
      <td>xlarge</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 400m
  memory: 1536Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 2000m
  memory: 4192Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
    <tr>
      <td>xxlarge</td>
      <td>
        <pre><code class="language-yaml">requests:
  cpu: 800m
  memory: 4192Mi
  ephemeral-storage: 50Mi
limits:
  cpu: 4000m
  memory: 8384Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
  </tbody>
</table>

### InitContainers
Setting values for initContainers follows the same input scheme as containers with the addition that you have to specify a mandatory `weight` value
because initContainers are ordered.

The `weight` value can range between 1-999 (<1000, >0) and the list of initContainers will be sorted in descending order,
meaning that the highest weight will be the first item of the list.

These example values ...

```yaml
---
...
deployment:
  ...
  pod:
    ...
    initContainers:
      strawweight:
        weight: 1
        ...

      heavyweight:
        weight: 800
        ...

      welterweight:
        weight: 400
        ...
  ...
```

... generate this YAML output:

```yaml
---
apiVersion: v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      initContainers:
        - name: heavyweight
          ...
        - name: welterweight
          ...
        - name: strawweight
          ...
```

## Config and secret items
TBD

## Certificate items
TBD

## ExternalSecret items
TBD
