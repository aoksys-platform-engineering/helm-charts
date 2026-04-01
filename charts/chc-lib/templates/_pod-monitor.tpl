{{/*
Template to generate a "PodMonitor" manifest from.

See "https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMonitor" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.pod-monitor.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ .name | default (include "common.names.fullname" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  jobLabel: app.kubernetes.io/instance
  podMetricsEndpoints: {{ include "common.tplvalues.render" (dict "value" .values.podMetricsEndpoints "context" $ctx) | nindent 4 }}
  namespaceSelector:
    matchNames:
      - {{ $ctx.Release.Namespace }}

  selector:
    matchLabels: {{ include "common.labels.matchLabels" $ctx | nindent 6 }}
{{- end }}
{{- end }}
