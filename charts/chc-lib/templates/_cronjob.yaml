{{- define "chc-lib.cronjob" }}
{{- $cronjob := .Values.cronjob }}
{{- $jobs := .Values.cronjob.jobs }}
{{- if $cronjob.create }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $cronjob.labels)
      "annotations" (list .Values.commonAnnotations $cronjob.annotations)
      "context" $) | nindent 2 }}
spec:
  concurrencyPolicy: {{ $cronjob.concurrencyPolicy }}
  successfulJobsHistoryLimit: {{ $cronjob.successfulJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $cronjob.failedJobsHistoryLimit }}
  schedule: {{ $cronjob.schedule | quote }}
  timeZone: {{ $cronjob.timeZone }}
  startingDeadlineSeconds: {{ $cronjob.startingDeadlineSeconds }}
  {{- if $cronjob.suspend }}
  suspend: true
  {{- end }}
  jobTemplate:
    metadata:
      {{- include "chc-lib.render.labelsAnnotations" (dict
        "labels" (list .Values.commonLabels $jobs.labels)
        "annotations" (list .Values.commonAnnotations $jobs.annotations)
        "context" $) | nindent 6 }}

    spec: {{ include "chc-lib.render.jobSpec" (dict "values" $jobs "defaultRegistry" .Values.imageRegistry "context" $) | nindent 6 }}
{{- end }}
{{- end }}
