{{/*
Template to generate a "StatefulSet" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#statefulset-v1-apps" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.stateful-set.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  {{- if .values.minReadySeconds }}
  minReadySeconds: {{ .values.minReadySeconds }}
  {{- end }}
  {{- if .values.persistentVolumeClaimRetentionPolicy }}
  persistentVolumeClaimRetentionPolicy: {{ .values.persistentVolumeClaimRetentionPolicy | toYaml | nindent 4 }}
  {{- end }}
  podManagementPolicy: {{ .values.podManagementPolicy }}
  {{- if .values.replicas }}
  replicas: {{ .values.replicas }}
  {{- end }}
  {{- if .values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ .values.revisionHistoryLimit }}
  {{- end }}
  serviceName: {{ .values.serviceName | default (include "common.names.fullname" $ctx) }}
  {{- if .values.updateStrategy }}
  updateStrategy: {{ .values.updateStrategy | toYaml | nindent 4 }}
  {{- end }}
  {{- if .values.volumeClaimTemplates }}
  volumeClaimTemplates: {{ include "common.tplvalues.render" (dict "value" .values.volumeClaimTemplates "context" $ctx) | nindent 4 }}
  {{- end }}
  selector:
    matchLabels: {{ include "common.labels.matchLabels" $ctx | nindent 6 }}

  template:
    metadata:
      {{- include "chc-lib.compute.labels-and-annotations" (dict
        "labels" (list $ctx.Values.commonLabels (.values.pods).labels)
        "annotations" (list $ctx.Values.commonAnnotations (.values.pods).annotations)
        "context" $ctx) | nindent 6 }}

    {{- /* We use "mergeOverwrite" and "deepCopy" here to ensure chc-lib default values are always applied but not modified */}}
    spec: {{ include "chc-lib.specs.pod" (dict "values" (mergeOverwrite (deepCopy $ctx.Values.pod) .values.pods) "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 6 }}
{{- end }}
{{- end }}
