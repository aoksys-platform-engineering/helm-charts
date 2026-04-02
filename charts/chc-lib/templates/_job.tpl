{{/*
Template to generate a "Job" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#job-v1-batch" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.job.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: batch/v1
kind: Job
metadata:
  {{- if .values.generateName }}
  generateName: {{ printf "%s-" (include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx)) }}
  {{- else }}
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  {{- end }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}

{{- /* We use "mergeOverwrite" and "deepCopy" here to ensure chc-lib default values are always applied but not modified */}}
spec: {{ include "chc-lib.specs.job" (dict "values" (mergeOverwrite (deepCopy $ctx.Values.job) .values) "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
