# chc-lib

![Version: 0.9.8](https://img.shields.io/badge/Version-0.9.8-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

Library chart to provide reusable functions and templates to compose application charts with.

**Homepage:** <https://bitbucket.central.aws.aok-systems.de/projects/PAAS/repos/chc-lib>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Oliver Geyer | <Oliver.Geyer@sys.aok.de> | <https://www.aok-systems.de/startseite.html> |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | common | 2.31.3 |

# Usage
Include chc-lib as a dependency in your application chart to use it,
as it cannot be installed or templated on its own:

```bash
$ helm template --generate-name chc-lib                                                               
Error: library charts are not installable
```

Add the following ``dependencies`` block to your chart’s ``Chart.yaml`` to use the chc-lib:

```yaml
# Chart.yaml of your application chart
---
...
dependencies:
  - name: chc-lib
    version: 0.9.8
    repository: https://nexus.central.aws.aok-systems.de/repository/helm-cloud-services
    # The "import-values" stanza is crucial to correctly import default values provided by the chc-lib.
    import-values:
      - defaults
```

# Values
This section outlines the `values.yaml` settings used to configure the templates provided by the chc-lib.

## Dynamic values
When ``Goes through tpl`` (or similar) is mentioned in the description of a value,
it means that you can use helms templating syntax to dynamically set the value when templates are rendered.

You need to make sure that dynamic values are quoted to be rendered correctly:

```yaml
# The values file of your app
---
...
podLabels:
  # This value needs to be quoted, because it will be set dynamically
  example: "{{ .Release.Namespace }}"

service:
  ...
  ports:
    # The value for "name" needs to be quoted even though it has a string suffix ("-https")
    - name: "{{ .Release.Name }}-https"
      port: 443
      targetPort: 8443
      nodePort: 10443
      porotocol: TCP

rbac:
  create: true
  ...
  role:
    rules:
      - verbs:
          - use
        apiGroups:
          - ""
        resources:
          - configmaps
        resourceNames:
          # List items needs to be quoted, too
          - "{{ .Release.Name }}"
...
```

Many templates use `tpl` for their values to take full advantage of helms templating engine.
Use them whenever possible to minimize the number of values files needed for different stages and environments.

## Common values
Values that are used across various templates.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| nameOverride | string | `""` | Used to override the base name for all resources. |
| fullnameOverride | string | `""` | Used to override the full name for all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. Values go through tpl. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. Values go through tpl. |
| podLabels | object | `{}` | Labels to add to all pods in addition to "commonLabels". Values go through tpl. |
| podAnnotations | object | `{}` | Annotations to add to all pods in addition to "commonAnnotations". Values go through tpl. |
| podSecurityContext | string | `"default"` | Security context to add to all pods. Can be freely defined as a dict, or a preset name can be supplied as a string. Available presets: "default".  |

## Controller values
Values that can be set at ``.Values.controller.<Value>``. These values are used in the deployment and statefulset template.
Deployment or statefulset specific values have to be set at ``.Values.deployment.<Value>`` and ``.Values.statefulset.<Value>``.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| kind | string | `"Deployment"` | Controller kind to create. Can be "Deployment" or "StatefulSet". |
| labels | object | `{}` | Labels to add to the controller in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the controller in addition to "commonAnnotations". Values go through tpl. |
| replicas | int | `1` | Number of pod replicas to create by the controller. |
| updateStrategy | object | `{"type":"Recreate"}` | Update strategy for pods managed by the controller. |
| affinity.podAffinity | object | `{}` | Pod affinity to set for pod scheduling. Useful to ensure that pod replicas are placed on the same node. Can be freely defined by supplying a dict, or a preset can be used by supplying a preset name as string. See 'Pod affinity presets' section in README for more. |
| affinity.podAntiAffinity | string | `"soft"` | Pod anti affinity to set for pod scheduling. Useful to ensure that pod replicas are placed on different nodes. Can be freely defined by supplying a dict, or a preset can be used by supplying the preset name as string. See 'Pod affinity presets' section in README for more. |
| affinity.nodeAffinity | object | `{}` | Node affinity to set for pod scheduling. Useful to ensure that pods are placed on a specific node. |
| tolerations | list | `[]` | Tolerations to set for pod scheduling. |
| hostAliases | list | `[]` | List of host aliases to inject into the pod. |
| initContainers | object | `{}` | InitContainers to inject into the pod. Values have to be provided as dict, not as list. Keys are used for the "name" value of each entry. Values go through tpl. Using a dict, instead of a list, is done to ensure proper merging of values when layering files. See 'InitContainers' section in README for more. |

### Pod affinity presets
This section provides example values and explains the usage of the ``.Values.controller.affinity.podAffinity`` and
``.Values.controller.affinity.podAntiAffinity`` stanzas for the controller, because values for them can be provided as dict or string.
Values for the ``.Values.controller.affnity.nodeAffinity`` stanza have to be provided as dict, because no presets exist for it.

When providing values for ``podAffinity`` and ``podAntiAffinity`` as dict, they are pasted as-is into the template.
This ensures that you can freely define pod (anti-) affinities as you need them, e.g. when using another topologyKey than ``kubernetes.io/hostname``.

When providing those values as string, you can choose between a ``soft`` and ``hard`` preset:

The ``soft`` preset returns a pod (anti-) affinity that is *preferred* to be fullfilled by the scheduler when deciding where to place pods.
Using a soft pod (anti-) affinity will never block the scheduling of a pod, even if it cannot be fullfilled by the scheduler.

The ``hard`` preset returns a pod (anti-) affinity that is *required* to be fullfilled by the scheduler when deciding where to place pods.
When the pod (anti-) affinity cannot be fullfilled by the scheduler, the scheduling of a pod is blocked.
Because of that, the ``hard`` preset should only be used when it is mandatory to schedule pods this way for the application to work.

Example values:

```yaml
# freely defined podAntiAffinity
---
...
controller:
  ...
  affinities:
    ...
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: "topology.kubernetes.io/zone"
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/instance
                operator: In
                values:
                  - chc-lib-unittests
...
```

```yaml
# using the "hard" preset for podAntiAffinity
---
...
controller:
  ...
  affinities:
    ...
    podAntiAffinity: hard
...
```

### InitContainers
This section provides example values and explains the usage of the ``.Values.controller.initContainers`` stanza
because default values are set to an empty dict.

When specifying initContainers, it may be necessary to guarantee the order in which initContainers are
executed. Because we are not using a list to specify the initContainers in our values,
we need to be able to ensure the order of initContainer execution otherwise.

Because of this, every initContainer should specify a ``weight`` field which is used for ordering.
If the weight field is missing, a default weight of "0" will be applied. Since initContainers are executed in
descending order regarding their weight, initContainers without the weight field will be executed last and ordering
between multiple initContainers with a weight of "0" cannot be guaranteed.

When specifying 3 initContainers with a weight of nil (missing), 567 and 123, they are executed in the order of
``567 -> 123 -> 0``.

Example values:

```yaml
---
...
controller:
  ...
  initContainers:
    # the key "db-check" will be used as value for the "name" field
    db-check:
      # the "weight" field will be removed after ordering in the rendered template
      weight: 567
      image: busybox:1.28
      command:
        - sh
        - -c
        - "until nc -z postgres.{{ .Release.Namespace }} 5432; do echo waiting for postgres; sleep 2; done"

    echo:
      # missing "weight" field here, so a weight of "0" is applied
      image: busybox:1.28
      command:
        - sh
        - -c
        - "echo 'hello world!'"

    liquibase:
      weight: 123
      image: liquibase:latest
      # all key/values go through tpl, so you can add all fields supported by the initContainers schema
      # (https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec)
      env:
        - name: LIQUIBASE_COMMAND_URL
          value: '{{ .Values.config.db.url }}'

        - name: LIQUIBASE_COMMAND_USERNAME
          valueFrom:
            secretKeyRef:
              key: username.ddl
              name: '{{ .Values.config.secretRefs.jdbcDdl }}'

        - name: LIQUIBASE_COMMAND_PASSWORD
          valueFrom:
            secretKeyRef:
              key: password.ddl
              name: '{{ .Values.config.secretRefs.jdbcDdl }}'
...
```

Templated output:

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
        - name: db-check
          image: busybox
          command:
            - sh
            - -c
            - "until nc -z postgres.aoksystems 5432; do echo waiting for postgres; sleep 2; done"

        - name: liquibase
          image: liquibase
          env:
            - name: LIQUIBASE_COMMAND_URL
              value: postgres.aoksystems

            - name: LIQUIBASE_COMMAND_USERNAME
              valueFrom:
                secretKeyRef:
                  key: username.ddl
                  name: chc-lib-unitests-psql

            - name: LIQUIBASE_COMMAND_PASSWORD
              valueFrom:
                secretKeyRef:
                  key: password.ddl
                  name: chc-lib-unitests-psql

        - name: echo
          image: busybox
          command:
            - sh
            - -c
            - "echo 'hello world!'"
...
```

## Deployment values
Values that can be set at ``.Values.deployment.<Value>`` to configure the deployment template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| revisionHistoryLimit | int | `5` | Number of ReplicaSet revisions to keep. |

## StatefulSet values
Values that can be set at ``.Values.statefulset.<Value>`` to configure the statefulset template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|

## Horizontal Pod Autoscaler (HPA) values
Values that can be set at ``.Values.hpa.<Value>`` to configure the hpa template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| create | bool | `false` | Toggle to enable/disable the creation of the hpa. |
| labels | object | `{}` | Labels to add to the hpa in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the hpa in addition to "commonAnnotations". Values go through tpl. |
| minReplicas | int | `1` | Sets the "minReplicas" spec for the hpa. |
| maxReplicas | int | `3` | Sets the "maxReplicas" spec for the hpa. |
| targetCPUUtilizationPercentage | int | `80` | Sets the "targetCPUUtilizationPercentage" spec for the hpa. |
| targetMemoryUtilizationPercentage | string | `nil` | Sets the "targetMemoryUtilizationPercentage" spec for the hpa. |

## Service values
Values that can be set at ``.Values.service.<Value>`` to configure the service template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| type | string | `"ClusterIP"` | Type of the service to create. |
| labels | object | `{}` | Labels to add to the service in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the service in addition to "commonAnnotations". Values go through tpl. |
| sessionAffinity | string | `"None"` | Session affinity to control how requests are routed. Can be "ClientIP" or "None". |
| sessionAffinityConfig | string | `nil` | Session affinity configs to be set in addition to "sessionAffinity". |
| ports | list | `[{"name":"https","porotocol":"TCP","port":443,"targetPort":8443}]` | Port configs for the service. Values go through tpl. |

## ServiceAccount values
Values that can be set at ``.Values.serviceAccount.<Value>`` to configure the serviceaccount template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| create | bool | `true` | Toggle to enable/disable creation of the serviceaccount. |
| name | string | `""` | Name of the serviceaccount to use. Will be generated, if empty. |
| labels | object | `{}` | Labels to add to the serviceaccount in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the serviceaccount in addition to "commonAnnotations". Values go through tpl. |
| automountServiceAccountToken | bool | `false` | Toggle to enable/disable the "automountServiceAccountToken" feature. Mounting the serviceaccount token is only necessary if your app calls the K8s API directly. |

## Role-Based Access Control (RBAC) values
Values that can be set at ``.Values.rbac.<Value>`` to configure the role and rolebinding templates.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| create | bool | `false` | Toggle to enable/disable creation of RBAC resources. |
| namespaceOverride | string | `""` | Namespace to create RBAC resources in. If empty or unset, "{{ .Release.Namespace }}" is used. |
| role.labels | object | `{}` | Labels to add to the role in addition to "commonLabels". Values go through tpl. |
| role.annotations | object | `{}` | Annotations to add to the role in addition to "commonAnnotations". Values go through tpl. |
| role.rules | list | `[]` | Rules to add to the role. Values go through tpl. |
| roleBinding.labels | object | `{}` | Labels to add to the rolebinding in addition to "commonLabels". Values go through tpl. |
| roleBinding.annotations | object | `{}` | Annotations to add to the rolebinding in addition to "commonAnnotations". Values go through tpl. |

## Pod Disruption Budget (PDB) values
Values that can be set at ``.Values.pdb.<Value>`` to configure the pdb template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| create | bool | `false` | Toggle to enable/disable creation of the pdb. |
| labels | object | `{}` | Labels to add to the pdb in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the pdb in addition to "commonAnnotations". Values go through tpl. |
| minAvailable | int | `1` | Sets the minAvailable spec for the pdb. |
| maxUnavailable | int | `1` | Sets the maxUnavailable spec for the pdb. Set "minAvailable" to nil (~) for this to take effect. |

## Prometheus-Operator values
Values that can be set at ``.Values.prometheusOperator.<Value>`` to enable the usage of related custom resources.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| enabled | bool | `false` | Toggle to enable/disable the prometheus-operator integration. Should be set to "true" if the prometheus-operator is installed in your cluster. |

### PodMonitor values
Values that can be set under ``.Values.prometheusOperator.podMonitor.<Value>`` to configure the podMonitor template.

| Value | Type | Default | Description |
|-------|------|-------------|---------|
| create | bool | `false` | Toggle to enable/disable the creation of the podMonitor resource. |
| namespaceOverride | string | `""` | Namespace to create the podMonitor resource in. If empty or unset, "{{ .Release.Namespace }}" is used. |
| labels | object | `{}` | Labels to add to the podMonitor in addition to "commonLabels". Values go through tpl. |
| annotations | object | `{}` | Annotations to add to the podMonitor in addition to "commonAnnotations". Values go through tpl. |
| podMetricsEndpoints | object | `{}` | Values to configure the "podMetricsEndpoints" of the podMonitor. Values have to be provided as dict, not as list. Keys are used for the "port" value of each entry. Values go through tpl. Using a dict, instead of a list, is done to ensure proper merging of values when layering files. See 'PodMonitor "podMetricsEndpoints" example values' section in README for more. |

#### PodMonitor "podMetricsEndpoints" example values
This section provides examples values for the usage of the ``podMetricsEndpoints`` stanza for the podMonitor resource,
because default values are set to an empty dict.

Example values:

```yaml
---
prometheusOperator:
  enabled: true
  podMonitor:
    create: true
    podMetricsEndpoints:
      # The "http-management" key will be used for the "port" value in the podMonitor resource
      http-management:
        # Key/value pairs go through tpl and can be extended arbitrarily. These are just example values.
        # See "https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMetricsEndpoint"
        # for the full "podMetricsEndpoints" spec.
        path: /actuator/prometheus
        scheme: http
        interval: 30s
        basicAuth:
          username:
            name: "{{ .Release.Name }}"
            key: username

          password:
            name: "{{ .Release.Name }}"
            key: password
```

Templated result:

```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  ...
spec:
  ...
  podMetricsEndpoints:
    - port: http-management
      interval: 30s
      path: /actuator/prometheus
      scheme: http
      basicAuth:
        password:
          key: password
          name: chc-lib-unittests
        username:
          key: username
          name: chc-lib-unittests
```
