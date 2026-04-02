{{/*
Template to generate a "Deployment" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#deploymentspec-v1-apps" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.deployment.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: apps/v1
kind: Deployment
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
  {{- if .values.paused }}
  paused: true
  {{- end }}
  {{- if .values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ .values.progressDeadlineSeconds }}
  {{- end }}
  {{- if .values.replicas }}
  replicas: {{ .values.replicas }}
  {{- end }}
  {{- if .values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ .values.revisionHistoryLimit }}
  {{- end }}
  {{- if .values.strategy }}
  strategy: {{ .values.strategy | toYaml | nindent 4 }}
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
