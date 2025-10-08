{{- define "chc-lib.ingress" }}
{{- $ingress := .Values.ingress }}
{{- if $ingress.create }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $ingress.labels)
      "annotations" (list .Values.commonAnnotations $ingress.annotations)
      "context" $) | nindent 2 }}
spec:
  {{- with $ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}

  {{- if $ingress.rules }}
  rules: {{ include "common.tplvalues.render" (dict "value" $ingress.rules "context" $) | nindent 4 }}
  {{- else }}
  rules: {{ list | toYaml }}
  {{- end }}

  {{- if $ingress.tls }}
  tls: {{ include "common.tplvalues.render" (dict "value" $ingress.tls "context" $) | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
