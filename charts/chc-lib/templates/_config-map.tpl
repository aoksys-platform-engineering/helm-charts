{{/*
Template to generate a "ConfigMap" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#configmap-v1-core" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.config-map.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
data: {{ include "common.tplvalues.render" (dict "value" .values.data "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
