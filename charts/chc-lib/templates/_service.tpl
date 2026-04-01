{{/*
Template to generate a "Service" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#service-v1-core" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.service.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name | default (include "common.names.fullname" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  selector: {{ include "common.labels.matchLabels" $ctx | nindent 4 }}
  type: {{ .values.type }}
  {{- if .values.sessionAffinity }}
  sessionAffinity: {{ .values.sessionAffinity }}
  {{- end }}
  {{- if .values.sessionAffinityConfig }}
  sessionAffinityConfig: {{ .values.sessionAffinityConfig | toYaml | nindent 4 }}
  {{- end }}
  ports: {{ include "chc-lib.compute.list-from-dict" (dict "values" .values.ports "keyName" "name" "context" $ctx) | nindent 4 }}
{{- end }}
{{- end }}
