{{/*
Template to generate an "KafkaUser" manifest from.

See "https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaUser-reference" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.kafka-user.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  authentication: {{ .values.authentication | toYaml | nindent 4 }}
  authorization: {{ include "common.tplvalues.render" (dict "value" .values.authorization "context" $ctx) | nindent 4 }}
  {{- if .values.quotas }}
  quotas: {{ .values.quotas | toYaml | nindent 4 }}
  {{- end }}
  template:
    secret:
      metadata:
        {{- include "chc-lib.compute.labels-and-annotations" (dict
            "labels" (list $ctx.Values.commonLabels .values.secret.labels)
            "annotations" (list $ctx.Values.commonAnnotations .values.secret.annotations)
            "context" $ctx) | nindent 8 }}
{{- end }}
{{- end }}
