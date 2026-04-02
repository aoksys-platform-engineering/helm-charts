{{/*
Template to generate a "CronJob" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#cronjob-v1-batch" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.cron-job.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
{{- if not .values.schedule }}
{{- fail "The CronJob 'schedule' has to be set, but is nil/empty" }}
{{- end }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  {{- if .values.concurrencyPolicy }}
  concurrencyPolicy: {{ .values.concurrencyPolicy }}
  {{- end }}
  {{- if .values.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ .values.failedJobsHistoryLimit }}
  {{- end }}
  schedule: {{ .values.schedule | quote }}
  {{- if .values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ .values.startingDeadlineSeconds }}
  {{- end }}
  {{- if .values.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ .values.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if .values.suspend }}
  suspend: true
  {{- end }}
  {{- if .values.timeZone }}
  timeZone: {{ .values.timeZone }}
  {{- end }}
  jobTemplate:
    metadata:
      {{- include "chc-lib.compute.labels-and-annotations" (dict
          "labels" (list $ctx.Values.commonLabels .values.jobs.labels)
          "annotations" (list $ctx.Values.commonAnnotations .values.jobs.annotations)
          "context" $ctx) | nindent 6 }}

    {{- /* We use "mergeOverwrite" and "deepCopy" here to ensure chc-lib default values are always applied but not modified */}}
    spec: {{ include "chc-lib.specs.job" (dict "values" (mergeOverwrite (deepCopy $ctx.Values.job) .values.jobs) "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 6 }}
{{- end }}
{{- end }}
