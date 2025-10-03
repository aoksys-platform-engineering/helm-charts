{{- define "chc-lib.job" }}
{{- $job := .Values.job }}
{{- if $job.create }}
---
apiVersion: batch/v1
kind: Job
metadata:
  {{- if $job.generateName }}
  generateName: {{ printf "%s-" include "common.names.fullname" . }}
  {{- else }}
  name: {{ include "common.names.fullname" . }}
  {{- end }}
  namespace: {{ $job.namespaceOverride | default .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $job.labels)
      "annotations" (list .Values.commonAnnotations $job.annotations)
      "context" $) | nindent 2 }}
spec: {{ include "chc-lib.render.jobSpec" (dict "values" $job.spec "defaultRegistry" .Values.imageRegistry "context" $) | nindent 2 }}
{{- end }}
{{- end }}
