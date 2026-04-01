{{/*
Contains all key/values that can be used to configure a "job". Its meant to be used in "_job.tpl" and "_cronjob.tpl".

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#job-v1-batch" for the full API spec.

Input scheme:
  dict:
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.specs.job" -}}
{{- $ctx := .context -}}

{{- if .values.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ .values.activeDeadlineSeconds }}
{{- end }}
{{- if .values.backoffLimit }}
backoffLimit: {{ .values.backoffLimit }}
{{- end }}
{{- if and .values.backoffLimitPerIndex (eq .values.completionMode "Indexed") }}
backoffLimitPerIndex: {{ .values.backoffLimitPerIndex }}
{{- if .values.maxFailedIndexes }}
maxFailedIndexes: {{ .values.maxFailedIndexes }}
{{- end }}
{{- end }}
{{- if .values.completionMode }}
completionMode: {{ .values.completionMode }}
{{- end }}
{{- if .values.completions }}
completions: {{ .values.completions }}
{{- end }}
{{- if .values.parallelism }}
parallelism: {{ .values.parallelism | default 1 }}
{{- end }}
{{ if .values.podFailurePolicy }}
podFailurePolicy: {{ .values.podFailurePolicy | toYaml | nindent 2 }}
{{- end }}
{{- if .values.podReplacementPolicy }}
podReplacementPolicy: {{ .values.podReplacementPolicy }}
{{- end }}
{{- if .values.successPolicy }}
successPolicy: {{ .values.successPolicy | toYaml | nindent 2 }}
{{- end }}
{{- if .values.suspend }}
suspend: true
{{- end }}
{{- if .values.ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ .values.ttlSecondsAfterFinished }}
{{- end }}
template:
  metadata:
    {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels (.values.pods).labels)
      "annotations" (list $ctx.Values.commonAnnotations (.values.pods).annotations)
      "context" $ctx) | nindent 4 }}

  {{- /* We use "mergeOverwrite" here to ensure chc-lib default values are applied */}}
  spec: {{ include "chc-lib.specs.pod" (dict "values" (mergeOverwrite $ctx.Values.pod .values.pods) "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 4 }}
{{- end }}
