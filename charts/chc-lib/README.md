# chc-lib

![Version: 0.48.1](https://img.shields.io/badge/Version-0.48.1-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

Library chart to provide reusable templates to compose application charts with.

# Usage
Include `chc-lib` as dependency in your application chart
because it cannot be installed or templated on its own:

```bash
$ helm template --generate-name chc-lib
Error: library charts are not installable
```

Add these `dependencies` to your `Chart.yaml` to include it:

```yaml
# Chart.yaml of your application chart
---
...
dependencies:
  - name: chc-lib
    version: 0.48.1
    repository: https://aoksys-platform-engineering.github.io/helm-charts
    # Importing "defaults" is mandatory
    import-values:
      - defaults
```

# Template values
This section explains how to configure the templates that `chc-lib` provides.

## Dynamic values
When `Values go through tpl` (or similar) is mentioned in the description of a value,
you can use helms templating syntax to set this value.

Make sure that computed values are quoted to be rendered correctly:

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
      protocol: TCP
...
```

> [!NOTE]
>
> You cannot use more complex expressions like `{{ .Values.service.ports[0].name }}` or
> `{{ include "common.names.fullname" . }}`. This will result in templating errors.

All templates use dynamic values to take advantage of helms templating engine.
Use them whenever possible to streamline your configs for different stages and environments.

## Common
Values that are used in most templates.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| nameOverride | string | `""` | Used to override the base name for all resources. |
| fullnameOverride | string | `""` | Used to override the full name for all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. Values go through tpl. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. Values go through tpl. |
| imageRegistry | string | `""` | Default imageRegistry to use when no other registry is specified. |

## Pod
Values to configure the `pod` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the pod. |
| labels | object | `{}` | Labels to add to a pod in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to a pod in addition to "commonAnnotations". Values go through tpl. |
| activeDeadlineSeconds | int | `nil` | Duration in seconds a pod may be active on the node before the system will mark it as failed to kill its containers. Omitted, if nil or empty. |
| affinity.nodeAffinity | object | `{}` | Describes node affinity scheduling rules for a pod. Can be a preset name (string) or a dict. See [Affinities](#affinities) in README for more. |
| affinity.podAffinity | object | `{}` | Describes pod affinity scheduling rules for a pod. Can be a preset name (string) or a dict. See [Affinities](#affinities) in README for more. |
| affinity.podAntiAffinity | object | `{}` | Describes pod anti-affinity scheduling rules for a pod. Can be a preset name (string) or a dict. See [Affinities](#affinities) in README for more. |
| automountServiceAccountToken | bool | `false` | Toggle to enable automatic mounting of the serviceaccount token in a pod. Omitted, if not true. |
| containers | object | `{}` | Containers that are part of a pod. See [Containers](#containers) in README for more. |
| dnsPolicy | string | `nil` | DNS policy to use. Should probably be set to "ClusterFirstWithHostNet", if "hostNetwork=true". Omitted, if nil or empty. |
| hostAliases | list | `[]` | List of hosts and IPs that will be injected into a pods hosts file. Omitted, if nil or empty. |
| hostNetwork | bool | `false` | Toggle to start a pod in hostNetwork mode. Omitted, if not true. |
| imagePullSecrets | list | `[]` | List of references to secrets in the same namespace to use for pulling any of the images that are part of a pod. Omitted, if nil or empty. |
| initContainers | object | `{}` | Init containers that are part of a pod. See [InitContainers](#initcontainers) in README for more. |
| nodeName | string | `""` | Name of a node to schedule a pod to. Mainly useful for debugging purposes. Omitted, if nil or empty. |
| nodeSelector | object | `{}` | Node selector for pod scheduling. Simpler to use than "affinity.nodeAffinity", but limited to simple label selectors. Omitted, if nil or empty. |
| priorityClassName | string | `""` | Name of a priorityClass to use for a pod. Omitted if nil or empty. |
| restartPolicy | string | `"Always"` | Restart policy for all containers within the pod. One of "Always", "OnFailure", "Never". Omitted, if nil or empty. |
| securityContext | string | `"default"` | Security context to use for a pod. Can be a preset name (string) or a dict. See [PodSecurityContext](#podsecuritycontext) in README for more. |
| serviceAccountName | string | `"default"` | Name of the serviceAccount to use for a pod. |
| terminationGracePeriodSeconds | string | `nil` | Seconds to wait for graceful termination of a pod, when a SIGTERM/SIGKILL is send. Omitted, if nil or empty. |
| tolerations | list | `[]` | Tolerations for pod scheduling. Omitted, if nil or empty. |
| volumes | object | `{}` | Volumes to mount into a pod. Follows the "List from dict" input schema. See [List from dict](#list-from-dict) in README for more. Omitted, if nil or empty. |

## Job
Values to configure the `job` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the job. |
| labels | object | `{}` | Labels to add to a job in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to a job in addition to "commonAnnotations". Values go through tpl. |
| generateName | bool | `false` | Toggle to enable/disable the automatic creation of a unique resource name by the kubernetes API server. Omitted, if not true. |
| activeDeadlineSeconds | int | `300` | Specifies the duration in seconds that the job may be active before the system tries to terminate it. Omitted, if nil or empty. |
| backoffLimit | int | `3` | The number of retries before marking this job failed. Omitted, if nil or empty. |
| backoffLimitPerIndex | int | `nil` | The limit for the number of retries within an index before marking this index as failed. Only takes effect if "completionMode=Indexed". Omitted, if nil or empty. |
| maxFailedIndexes | int | `nil` | Specifies the maximal number of failed indexes before marking the job as failed, when backoffLimitPerIndex is set. Omitted, if nil or empty. |
| completionMode | string | `nil` | Specifies how pod completions are tracked. Can be set to "NonIndexed" or "Indexed". Omitted, if nil or empty. |
| completions | int | `1` | The desired number of successfully finished pods the job should be run with. Omitted, if empty. |
| parallelism | int | `1` | The maximum desired number of pods the job should run at any given time. Omitted, if nil or empty. |
| podFailurePolicy | string | `nil` | Specifies the policy of handling failed pods. Omitted, if nil or empty. |
| podReplacementPolicy | string | `nil` | Specifies when to create new pods that replace old ones. Omitted, if nil or empty. |
| successPolicy | string | `nil` | Specifies the policy when the job can be declared as succeeded. Omitted, if nil or empty. |
| suspend | bool | `false` | Specifies whether the job should create new pods, or not. Omitted, if not true. |
| ttlSecondsAfterFinished | int | `600` | Time in seconds after which a finished pod is cleaned up automatically. If unset, pods are never cleaned up. Omitted, if nil or empty. |
| pods | object | `{}` | Values to configure the pods managed by the job. You can use all fields described in the [Pod](#pod) section of the README here. |

## Deployment
Values to configure the `deployment` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the deployment. |
| labels | object | `{}` | Labels to add to the deployment in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the deployment in addition to "commonAnnotations". Values go through tpl. |
| minReadySeconds | int | `nil` | Number of seconds to wait before a pod is considered available, if no containers are crashing. Omitted, if nil or empty. |
| paused | bool | `false` | Indicates that the deployment is paused. Omitted, if not true. |
| progressDeadlineSeconds | int | `nil` | The maximum time in seconds for a deployment to make progress before it is considered to be failed. Omitted, if nil or empty. |
| replicas | int | `nil` | Number of desired pods to create. Omitted, if nil or empty. |
| revisionHistoryLimit | int | `nil` | Number of old ReplicaSets to retain to allow rollback. Omitted, if nil or empty. |
| strategy | object | `{}` | The deployment strategy to use to replace existing pods with new ones. Omitted, if nil or empty. |
| pods | object | `{}` | Values to configure the pods managed by the deployment. You can use all fields described in the [Pod](#pod) section of the README here. |

## StatefulSet
Values to configure the `stateful-set` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the statefulSet. |
| labels | object | `{}` | Labels to add to the statefulSet in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the statefulSet in addition to "commonAnnotations". Values go through tpl. |
| minReadySeconds | int | `nil` | Number of seconds to wait before a pod is considered available, if no containers are crashing. Omitted, if nil or empty. |
| persistentVolumeClaimRetentionPolicy | object | `{}` | Policy to manage the lifecycle of PVCs created from "volumeClaimTemplates". See https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#statefulsetpersistentvolumeclaimretentionpolicy-v1-apps for which values can be used. Omitted, if empty or nil. |
| podManagementPolicy | string | `"OrderedReady"` | Policy to control how pods are created during initial scale up, when replacing pods on nodes, or when scaling down. Can be "OrderedReady" or "Parallel". |
| replicas | int | `nil` | Number of desired pods to create. Omitted, if nil or empty. |
| revisionHistoryLimit | int | `nil` | Maximum number of revisions to keep in the statefulSet's revision history to perform rollbacks. Omitted, if nil or empty. |
| serviceName | string | `nil` | Name of the service that governs this StatefulSet. Defaults to the name of the statefulSet, if nil or empty. |
| updateStrategy | object | `{}` | The statefulSet updateStrategy to use to replace existing pods with new ones. Omitted, if nil or empty. |
| volumeClaimTemplates | list | `[]` | A list of storage claims that are created and attached to the statefulSet automatically. Useful to dynamically provision PVCs that are mapped to each pod controlled by the statefulSet. It takes precedence over volumes defined in the PodTemplate, if a volume and volumeClaimTemplate have the same name.  Should be used with caution because volumes managed by a volumeClaimTemplate cannot be resized dynamically after their creation. Values go through tpl. Omitted, if empty or nil. |
| pods | object | `{}` | Values to configure the pods managed by the statefulSet. You can use all fields described in the [Pod](#pod) section of the README here. |

## CronJob
Values to configure the `cron-job` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the cronJob. |
| labels | object | `{}` | Labels to add to the cronJob in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the cronJob in addition to "commonAnnotations". Values go through tpl. |
| concurrencyPolicy | string | `"Forbid"` | Specifies how to treat concurrent executions of a Job. Omitted, if nil or empty. |
| failedJobsHistoryLimit | int | `1` | Number of failed finished jobs to retain. Omitted, if nil or empty. |
| schedule | string | `"@daily"` | Schedule to launch jobs in Cron format, see https://en.wikipedia.org/wiki/Cron. Templating fails, if nil or empty. |
| startingDeadlineSeconds | int | `nil` | Deadline in seconds for starting the job if it misses scheduled time for any reason. Missed jobs executions will be counted as failed ones. Omitted, if nil or empty. |
| successfulJobsHistoryLimit | int | `1` | Number of successful finished jobs to retain. Omitted, if nil or empty. |
| suspend | bool | `false` | Toggle to suspend subsequent executions. Omitted, if not true. |
| timeZone | string | `"Europe/Berlin"` | Name of the time zone for the given schedule. See https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. Defaults to the time zone of the kube-controller-manager process. Omitted, if nil or empty. |
| jobs | object | `{}` | Values to configure the job managed by the cronJob. You can use all fields described in the [Job](#job) section of the README here. |

## Service
Values to configure the `service` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of a service. |
| labels | object | `{}` | Labels to add to the service in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the service in addition to "commonAnnotations". Values go through tpl. |
| type | string | `"ClusterIP"` | Type of the service to create. |
| sessionAffinity | string | `"ClientIP"` | Session affinity to control how requests are routed. Can be "ClientIP" or "None". Omitted if nil or empty. |
| sessionAffinityConfig | string | `nil` | Session affinity configs to be set in addition to "sessionAffinity". Omitted if nil or empty. |
| ports | object | `{}` | Ports for the service. Follows the "list-from-dict" input schema. See [List from dict](#list-from-dict) in README for more. |

## Ingress
Values to configure the `ingress` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the ingress. |
| labels | object | `{}` | Labels to add to the ingress in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the ingress in addition to "commonAnnotations". Values go through tpl. |
| defaultBackend | string | `""` | Backend that should handle any requests that don't match a rule. If "rules" are nil or empty, "defaultBackend" must be set. Omitted, if "rules" are set and this is nil or empty. |
| className | string | `""` | Name of the ingressClass to use. Omitted, if nil or empty. |
| rules | list | `[]` | List of rules for the ingress. Values go through tpl. See https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#ingressrule-v1-networking-k8s-io for more. |
| tls | list | `[]` | List of TLS hosts to serve. Values go through tpl. Omitted, if nil or empty. See https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#ingresstls-v1-networking-k8s-io for more. |

## ServiceAccount
Values to configure the `service-account` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the serviceAccount. |
| labels | object | `{}` | Labels to add to the serviceAccount in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the serviceAccount in addition to "commonAnnotations". Values go through tpl. |
| automountServiceAccountToken | bool | `false` | Toggle to enable/disable the automatic mount of the serviceAccount token. |
| name | string | `""` | Name of the serviceAccount to create. Value goes through tpl. Templating fails if "create=true" and "name=default". |

## Role
Values to configure the `role` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the role. |
| namespaceOverride | string | `""` | Overrides the namespace to create the role in. It will be created in the release namespace, if empty or nil. |
| labels | object | `{}` | Labels to add to the role in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the role in addition to "commonAnnotations". Values go through tpl. |
| rules | list | `[]` | List of RBAC rules for the role. Values go through tpl. |

## RoleBinding
Values to configure the `role-binding` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the roleBinding. |
| namespaceOverride | string | `""` | Overrides the namespace to create the roleBinding in. It will be created in the release namespace, if empty or nil. |
| labels | object | `{}` | Labels to add to the roleBinding in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the roleBinding in addition to "commonAnnotations". Values go through tpl. |
| subject.kind | string | `"ServiceAccount"` | Kind of the subject to attach the roleBinding to. |
| subject.subject | string | `""` | Name of the subject to attach the roleBinding to. Will be computed, if nil or empty. |
| roleRef.apiGroup | string | `"rbac.authorization.k8s.io"` | apiGroup of the referenced role. |
| roleRef.kind | string | `"Role"` | kind of the referenced role. |
| roleRef.name | string | `""` | name of the referenced role. Will be computed, if nil or empty. |

## ConfigMap
Values to configure the `config-map` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the configMap. |
| labels | object | `{}` | Labels to add to the configMap in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the configMap in addition to "commonAnnotations". Values go through tpl. |
| data | object | `{}` | Data to store in the configMap. Values go through tpl. |

## Secret
Values to configure the `secret` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the secret. |
| labels | object | `{}` | Labels to add to the secret in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the secret in addition to "commonAnnotations". Values go through tpl. |
| stringData | object | `{}` | Data to store in the secret. Note that all data has to be provided in clear text, not base64 encoded. Values go through tpl. Note: If you want to keep sensitive data secure, use a backend (e.g. AWS Secrets Manager or HashiCorp Vault) and retrieve secrets at runtime via External Secrets Operator instead of storing them in values files. |

## PersistentVolume
Values to configure the `persistent-volume` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the persistentVolume. |
| labels | object | `{}` | Labels to add to the persistentVolume in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the persistentVolume in addition to "commonAnnotations". Values go through tpl. |
| spec | object | `{}` | Configures the "spec" section of the persistentVolume. Values go through tpl. See https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#persistentvolumespec-v1-core for more. |

## PersistentVolumeClaim
Values to configure the `persistent-volume-claim` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the persistentVolumeClaim. |
| labels | object | `{}` | Labels to add to the persistentVolumeClaim in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the persistentVolumeClaim in addition to "commonAnnotations". Values go through tpl. |
| spec | object | `{}` | Configures the "spec" section of the persistentVolumeClaim. Values go through tpl. See https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#persistentvolumeclaimspec-v1-core for more. |

## PodDisruptionBudget
Values to configure the `pod-disruption-budget` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the podDisruptionBudget. |
| labels | object | `{}` | Labels to add to the podDisruptionBudget in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the podDisruptionBudget in addition to "commonAnnotations". Values go through tpl. |
| maxUnavailable | int | `1` | Configures that an eviction is allowed, if at most "maxUnavailable" pods are unavailable after the eviction. |
| minAvailable | int | `1` | Configures that an eviction is allowed, if at least "minAvailable" pods will still be available after the eviction. This only takes effect if "maxUnavailable" is nil or empty. If both "maxUnavailable" and "minAvailable" are nil or empty, templating fails. |
| unhealthyPodEvictionPolicy | string | `"AlwaysAllow"` | Defines the criteria for when unhealthy pods should be considered for eviction. Can be "AlwaysAllow" or "IfHealthyBudget". Omitted, if nil or empty. |

## HorizontalPodAutoscaler
Values to configure the `horizontal-pod-autoscaler` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the horizontalPodAutoscaler. |
| labels | object | `{}` | Labels to add to the horizontalPodAutoscaler in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the horizontalPodAutoscaler in addition to "commonAnnotations". Values go through tpl. |
| scaleTargetRef.apiVersion | string | `"apps/v1"` | API version of the referent. |
| scaleTargetRef.kind | string | `"Deployment"` | Kind of the referent. |
| scaleTargetRef.name | string | `""` | Name of the referent. Will be compted, if nil or empty. |
| minReplicas | int | `1` | The lower limit number of pods to which the target can be scaled down to. |
| maxReplicas | int | `3` | The upper limit number of pods that can be scaled up to. Cannot be smaller than "minReplicas". |
| behavior | object | `{}` | Configures the scaling behavior of the target in both directions (scale up and down). Omitted, if nil or empty. See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#horizontalpodautoscalerbehavior-v2-autoscaling for more. |
| targetCPUUtilizationPercentage | int | `70` | The target average CPU utilization percentage across all pods. Omitted if nil or empty. |
| targetMemoryUtilizationPercentage | string | `nil` | The target average memory utilization percentage across all pods. Omitted if nil or empty. If both "targetCPUUtilizationPercentage" and "targetMemoryUtilizationPercentage" are nil/empty, templating fails. |

## Certificate
Values to configure the `certificate` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the certificate resource. Deployment fails, if corresponding custom resource definitions served by cert-manager are not installed in your cluster (https://cert-manager.io). |
| labels | object | `{}` | Labels to add to the certficate in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the certficate in addition to "commonAnnotations". Values go through tpl. |
| secret.name | string | `""` | Name of the corresponding secret to create. Will be computed, if nil or empty. |
| secret.labels | object | `{}` | Labels to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| secret.annotations | object | `{}` | Annotations to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| commonName | string | `"{{ .Release.Name }}"` | Requested common name X509 certificate subject attribute. Values go through tpl. Omitted, if nil or empty. |
| duration | string | `"720h0m0s"` | Requested lifetime of the certificate. Omitted, if nil or empty. |
| renewBefore | string | `""` | Configures how long before the currently issued certificate’s expiry cert-manager should renew the certificate. Omitted, if nil or empty. |
| renewBeforePercentage | int | `25` | "renewBeforePercentage" is like "renewBefore", except it is a relative percentage rather than an absolute duration. Omitted, if nil/empty or "renewBefore" is already set. |
| dnsNames | list | `["{{ .Release.Name }}","{{ .Release.Name }}.{{ .Release.Namespace }}","{{ .Release.Name }}.{{ .Release.Namespace }}.svc.cluster.local"]` | List of requested DNS subject alternative names. Values go through tpl. Omitted, if nil or empty. |
| keystores.jks.create | bool | `false` | Toggle to enable/disable the creation of a secret containing a JKS keystore. |
| keystores.jks.secretName | string | `"{{ .Release.Name }}-jks"` | Name of the secret containing the key to encrypt the keystore with. Values go through tpl. |
| keystores.pkcs12.create | bool | `false` | Toggle to enable/disable the creation of a secret containing a pkcs12 keystore. |
| keystores.pkcs12.secretName | string | `"{{ .Release.Name }}-pkcs12"` | Name of the secret containing the key to encrypt the keystore with. Values go through tpl. |
| issuerRef.group | string | `"cert-manager.io"` | API group of the issuer to use. |
| issuerRef.name | string | `"ca-issuer"` | Name of the (cluster)issuer to use. |
| issuerRef.kind | string | `"ClusterIssuer"` | Kind of issuer to use. |
| isCA | bool | `false` | Requested basic constraints isCA value. The isCA value is used to set the isCA field on the created CertificateRequest resources. Omitted, if not true. |
| usages | list | `[]` | Requested key usages and extended key usages. These usages are used to set the usages field on the created CertificateRequest resources. Omitted, if nil or empty. |
| privateKey | object | `{"algorithm":"RSA","encoding":"PKCS1","size":2048}` | Spec for how to create the the private key. See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificatePrivateKey for more. |
| revisionHistoryLimit | int | `3` | The maximum number of CertificateRequest revisions that are maintained in the certificate’s history. Omitted, if nil or empty. |
| nameConstraints | object | `{}` | x.509 certificate NameConstraint extension which MUST NOT be used in a non-CA certificate (isCA=false). See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.NameConstraints for more. |

## PodMonitor
Values to configure the `pod-monitor` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the podMonitor resource. Deployment fails, if corresponding custom resource definitions served by the prometheus-operator are not installed in your cluster (https://prometheus-operator.dev/). |
| namespaceOverride | string | `""` | Namespace to create the podMonitor resource in. If nil or empty, "{{ .Release.Namespace }}" is used. |
| labels | object | `{}` | Labels to add to the podMonitor in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the podMonitor in addition to "commonAnnotations". Values go through tpl. |
| podMetricsEndpoints | list | `[]` | List of endpoints where metrics are served from so they can be scraped by prometheus. Values go through tpl. See https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMetricsEndpoint for all available options. |

## ExternalSecret
Values to configure the `external-secret` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the externalsecret resource. Deployment fails, if corresponding custom resource definitions served by external-secrets operator are not installed in your cluster (https://external-secrets.io). |
| labels | object | `{}` | Labels to add to the externalsecret in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the externalsecret in addition to "commonAnnotations". Values go through tpl. |
| secret.name | string | `""` | Name of the corresponding secret to create. Will be computed, if nil or empty. |
| secret.type | string | `""` | Type of the corresponding secret to create. Omitted, if nil or empty. |
| secret.labels | object | `{}` | Labels to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| secret.annotations | object | `{}` | Annotations to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| secret.creationPolicy | string | `""` | Defines how to create the corresponding secret. Omitted, if empty or nil. |
| secret.deletionPolicy | string | `""` | Defines how to delete the corresponding secret. Omitted, if empty or nil. |
| refreshPolicy | string | `"OnChange"` | Determines how the externalsecret should be refreshed. Omitted, if nil or empty. |
| refreshInterval | string | `"24h0m0s"` | The amount of time before the values are read again from the SecretStore provider, specified as Golang duration string. |
| secretStoreRef.name | string | `"aws"` | Name of the SecretStore to use. |
| secretStoreRef.kind | string | `"ClusterSecretStore"` | Kind of the SecretStore to use. |
| basePath | string | `""` | Base path is prepended to the key of every remoteRef data item, if set. |
| decodingStrategy | string | `"Auto"` | Default decoding strategy to use for every remoteRef data item. |
| conversionStrategy | string | `"Default"` | Default conversion strategy to use every remoteRef data item. |
| metadataPolicy | string | `"Fetch"` | Default metadata policy to use every remoteRef data item. |
| data | list | `[]` | List of items that describe what data are fetched from a SecretStore and how to store it in a kubernetes secret. See https://external-secrets.io/latest/api/spec/#external-secrets.io/v1.ExternalSecretData for more. |

## KafkaUser
Values to configure the `kafka-user` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the kafkauser resource. Deployment fails, if corresponding custom resource definitions served by strimzi-kafka-operator are not installed in your cluster (https://strimzi.io). |
| namespaceOverride | string | `""` | Namespace to create the kafkauser resource in. If nil or empty, "{{ .Release.Namespace }}" is used. |
| labels | object | `{}` | Labels to add to the kafkauser in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the kafkauser in addition to "commonAnnotations". Values go through tpl. |
| secret.labels | object | `{}` | Labels to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| secret.annotations | object | `{}` | Annotations to add to the corresponding secret in addition to "commonLabels". Values go through tpl. |
| authentication | object | `{"type":"scram-sha-512"}` | Authentication mechanism to enable for the kafkauser. Supported authentication mechanisms are "scram-sha-512", "tls", and "tls-external". See https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaUser-reference for more. |
| authorization | object | `{"acls":[],"type":"simple"}` | Authorization rules for the kafkauser. Values go through tpl. See https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaUserAuthorizationSimple-reference for more. |
| quotas | object | `{}` | Request quotas to limit kafka broker resource usage caused by the kafkauser. Omitted, if nil or empty. |

## KafkaTopic
Values to configure the `kafka-topic` template.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| create | bool | `true` | Toggle to enable/disable the creation of the kafkatopic resource. Deployment fails, if corresponding custom resource definitions served by strimzi-kafka-operator are not installed in your cluster (https://strimzi.io). |
| namespaceOverride | string | `""` | Namespace to create the kafkatopic resource in. If nil or empty, "{{ .Release.Namespace }}" is used. |
| labels | object | `{}` | Labels to add to the kafkatopic in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the kafkatopic in addition to "commonAnnotations". Values go through tpl. |
| topicName | string | `""` | Name of the topic to create. Values go through tpl. Will be computed, if nil or empty. |
| partitions | int | `nil` | Number of partitions the topic should have. This cannot be decreased after topic creation. When absent, this will default to the broker configuration for "num.partitions". Omitted, if nil or empty. |
| replicas | int | `nil` | Number of replicas the topic should have across brokers. Defaults to the broker configuration for "default.replication.factor", if unset. Omitted, if nil or empty. |
| config | object | `{}` | Config for the topic. See https://kafka.apache.org/42/configuration/topic-configs/ for more. Omitted, if nil or empty. |

## Extra manifests
Values for `extraManifests` are a list of arbitrary kubernetes manifests to deploy. Values go through tpl.

This is a fallback mechanism to ensure complementary resources can be deployed
even if there is no dedicated `chc-lib` template yet.

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

# Input schemas
Because `chc-lib` is a library chart, values have sane defaults or are omitted from templated output
to rely on kubernetes defaults if not set explicitly.

Some values use custom data types and templating logic that require some explanation to use and configure them properly.
This section describes these custom implementations ("input schemas") and provides examples for them.

## Good to know
Values that depend on the metadata of a release, like "{{ .Release.Name }}" or "{{ .Release.Namespace }}",
are shown as "<computed>" in all example values.

Furthermore, the following keywords are used to describe how values behave when a chart is rendered:

* `mandatory`: If a value is "mandatory", there is no default value and the user has to provide a valid, non empty value for it. Otherwise, the chart will fail with an error when templates are rendered.
* `omitted`: If a value is "omitted", we rely on the kubernetes default value and the field will not be part of the templated output if the user doesn't set a non empty value for it.
* `computed`: If a value is "computed", it is generated in some way and the value may not be overwritten by a user at this path.
* `helm default labels`: When this is used, you don't have to provide a value, but provided values are merged with a set of always rendered default labels (https://helm.sh/docs/chart_best_practices/labels/#standard-labels).

## Affinities
When configuring "affinity.podAffinity" or "affinity.podAntiAffinity" for a pod, you can provide values as string or dict.

The rendered YAML output depends on the provided data type:
- Dict value: Values are used as-is without further processing. An empty dict (`{}`) is valid, too.
- String value: Checks if the value matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is printed and templating fails.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Returned YAML</th>
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
          &lt;computed&gt;</code></pre>
      </td>
    </tr>
    <tr>
      <td>hard</td>
      <td>
        <pre><code class="language-yaml">requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: kubernetes.io/hostname
    labelSelector:
      matchLabels:
        &lt;computed&gt;</code></pre>
      </td>
    </tr>
  </tbody>
</table>

> [!NOTE]
>
> Preset names for `podAffinity` and `podAntiAffinity` values are identical.

## PodSecurityContext
When configuring the `securityContext` for a pod, you can provide values as string or dict.

The rendered YAML output depends on the provided data type:
- Dict value: Values are used as-is without further processing. An empty dict (`{}`) is valid input, but it returns the content for the "default" preset. To render an empty dict, use the "openshift" preset.
- String value: Checks if the value matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, it returns an error message.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Returned YAML</th>
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
    <tr>
      <td>openshift</td>
      <td><pre><code class="language-yaml">&#35; Empty dict to let openshift manage it
{}</code></pre></td>
    </tr>
  </tbody>
</table>

## Containers
This section explains which values can be set when you configure a `container`.

| Value           | Type           | Default          | Description                                                                                                                                                                                                         |
|-----------------|----------------|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name            | string         | computed         | Value for the `name` field of the container. This is generated from the key of each dict item.                                                                                                                      |
| image           | dict           | mandatory        | Container image to use. Follows the `Images` input schema. See [Images](#images) in README for more.                                                                                                                |
| command         | list           | omitted          | List of commands to use as ENTRYPOINT for the container. If not specified, the ENTRYPOINT from the container image is used. Values go through tpl.                                                                  |
| args            | list           | omitted          | List of argument to provide for the ENTRYPOINT. Values go through tpl.                                                                                                                                              |
| securityContext | dict or string | "default" preset | Security context for the container. Can be a preset name (string) or a dict. See [ContainerSecurityContext](#containersecuritycontext) in README for more.                                                          |
| restartPolicy   | string         | omitted          | RestartPolicy defines the restart behavior of individual containers in a pod. This field may only be set for init containers. For non-init containers, the restart behavior is defined by the Pod's restart policy. |
| resources       | dict or string | "xsmall" preset  | Resources for the container. Can be a preset name (string) or a dict. See [Resources](#resources) in README for more.                                                                                               |
| volumeMounts    | dict           | omitted          | Volumes to mount in the container. Follows the `ListFromDict` input schema. See [ListFromDict](#listfromdict) in README for more.                                                                                   |
| env             | dict           | omitted          | ENVs to set for the container. Follows the `ListFromDict` input schema. See [ListFromDict](#listfromdict) in README for more.                                                                                       |
| ports           | dict           | omitted          | Ports for the container. Follows the `ListFromDict` input schema. See [ListFromDict](#listfromdict) in README for more.                                                                                             |
| startupProbe    | dict           | omitted          | StartupProbe indicates that the Pod has successfully initialized. If specified, no other probes are executed until this completes successfully.                                                                     |
| livenessProbe   | dict           | omitted          | Periodic probe of container liveness. Container will be restarted if the probe fails.                                                                                                                               |
| readinessProbe  | dict           | omitted          | Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails.                                                                                                 |

### Images
When setting values for a container `image`, provide them using the following input schema:

| Value      | Type   | Default                                   | Description                                                                                                                                                                         |
|------------|--------|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| registry   | string | omitted                                   | Registry to pull the container image from. If unset, the value of "imageRegistry" is used. |
| repository | string | mandatory                                 | Repository in the registry to pull the container image from.                                                                                                                        |
| tag        | string | `{{ .Chart.AppVersion }}` | Tag of the container image to pull.                                                                                                                                                 |
| digest     | string | omitted                                   | Image digest to use when pulling the container image.                                                                                                                                     |
| pullPolicy | string | omitted                                   | Policy when images are pulled from the registry. Can be "Always" or "IfNotPresent" Omitted, if unset.                                                                                                 |

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
When configuring the `securityContext` for a container, you can provide values as string or dict.

The output depends on the provided data type:
- Dict value: Value are used as-is without further processing. An empty dict (`{}`) is valid input too, but it returns the content for the "default" preset. To render an empty dict, use the "openshift" preset.
- String value: Checks if the value matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, it returns an error message.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Returned YAML</th>
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
    <tr>
      <td>openshift</td>
      <td><pre><code class="language-yaml">&#35; Empty dict to let openshift manage it
{}</code></pre></td>
    </tr>
  </tbody>
</table>

### Resources
When configuring the `resources` for a container, you can provide values as string or dict.

The output depends on the provided data type:
- Dict value: Values are used as-is without further processing. An empty dict (`{}`) is valid input too, but it returns the content of the "xsmall" preset.
- String value: Checks if the value matches a preset name and if it does, returns the corresponding YAML block. If it doesn't match a preset name, an error message is printed that lists all presets available.

<table>
  <thead>
    <tr>
      <th>Preset name</th>
      <th>Returned YAML</th>
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
  memory: 8384Mi
  ephemeral-storage: 1Gi</code></pre>
      </td>
    </tr>
  </tbody>
</table>

> [!NOTE]
>
> You can always configure custom values for container resources if these presets aren't a good fit for your workload.

## List from dict
This input schema accepts a dict with arbitrary key/value pairs and converts them into an unordered list.
This enables proper merging of values when layering values files.

It is used to across many templates to compute all kinds of values like `volumes`, `volumeMounts`, `ports`, `ENVs` and more.
For values that follow the `List from dict` input schema, each items `name` comes from its key.

All values are merged and processed using `tpl`.

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
          "{{ .Release.Name }}-configs":
            mountPath: /etc/config
        
          cache:
            mountPath: /cache

        ports:
          "{{ .Release.Name }}-https":
            containerPort: 8443
            protocol: TCP
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
              protocol: TCP
          ...
```

## InitContainers
This section explains which values can be set when you configure an `initContainer`.

Configuring initContainers follows the same input schema as containers with the addition of a mandatory `weight` value.
The `weight` value is necessary to generate an ordered list of initContainers to ensure their order of execution when a pod launches.

The `weight` value can range between 1-999 (<1000, >0) and the list of initContainers will be sorted in descending order (highest value goes first).
If an invalid `weight` value is provided, templating will fail and it returns an error message.

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
