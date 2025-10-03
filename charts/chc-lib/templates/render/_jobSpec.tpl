{{/*
Returns a templated jobSpec to use in the job and cronjob template.

See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#jobspec-v1-batch for more.

input scheme:
  dict:
    values: dict
    context: object (global chart context, has to be $)
*/}}

{{- define "chc-lib.render.jobSpec" -}}
{{- $ctx := .context -}}

activeDeadlineSeconds: {{ (.values).activeDeadlineSeconds | default 600 }}
backoffLimit: {{ (.values).backoffLimit | default 3 }}
{{- if and (.values).backoffLimitPerIndex (eq (.values).backoffLimitPerIndex "Indexed") }}
backoffLimitPerIndex: {{ (.values).backoffLimitPerIndex }}
{{- end }} 
completionMode: {{ (.values).completionMode | default "NonIndexed" }}
completions: {{ (.values).completions | default 1 }}
parallelism: {{ (.values).parallelism | default 1 }}
suspend: {{ (.values).suspend | default false }}
ttlSecondsAfterFinished: {{ (.values).ttlSecondsAfterFinished | default 86400 }}
template:
  metadata:
    {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $ctx.Values.commonLabels (.values.pods).labels)
      "annotations" (list $ctx.Values.commonAnnotations (.values.pods).annotations)
      "context" $ctx) | nindent 4 }}

  {{- if (.values).pods }}
  spec: {{ include "chc-lib.render.podSpec" (dict "values" .values.pods "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 4 }}
  {{- else }}
  spec: {}
  {{- end }}
{{- end }}
