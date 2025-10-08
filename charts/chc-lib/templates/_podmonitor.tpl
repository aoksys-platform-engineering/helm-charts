{{- define "chc-lib.podmonitor" }}
{{- $podmonitor := .Values.prometheusOperator.podMonitor -}}
{{- if and .Values.prometheusOperator.enabled $podmonitor.create }}
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ $podmonitor.namespaceOverride | default .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $podmonitor.labels)
      "annotations" (list .Values.commonAnnotations $podmonitor.annotations)
      "context" $) | nindent 2 }}
spec:
  jobLabel: app.kubernetes.io/instance
  namespaceSelector:
    matchNames:
      - {{ .Release.Namespace }}

  selector:
    matchLabels: {{ include "common.labels.matchLabels" . | nindent 6 }}

  {{ if $podmonitor.podMetricsEndpoints -}}
  podMetricsEndpoints:
  {{- range $k, $v := $podmonitor.podMetricsEndpoints }}
    - port: {{ $k }}
      {{- include "common.tplvalues.render" (dict "value" $v "context" $) | nindent 6 }}
  {{- end }}
  {{- else }}
  podMetricsEndpoints: {}
  {{- end }}
{{- end }}
{{- end }}
