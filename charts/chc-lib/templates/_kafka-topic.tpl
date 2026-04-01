{{/*
Template to generate an "KafkaTopic" manifest from.

See "https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaTopic-reference" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.kafka-topic.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: {{ .name | default (include "common.names.fullname" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  {{- if .values.topicName }}
  topicName: {{ tpl .values.topicName $ctx }}
  {{- end }}
  {{- if .values.partitions}}
  partitions: {{ .values.partitions }}
  {{- end }}
  {{- if .values.replicas}}
  replicas: {{ .values.replicas }}
  {{- end }}
  {{- if .values.config }}
  config: {{ .values.config | toYaml | nindent 4 }}
  {{- else }}
  config: {{ dict | toYaml }}
  {{- end }}
{{- end }}
{{- end }}
