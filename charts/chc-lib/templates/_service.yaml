{{- define "chc-lib.service" }}
{{- $service := .Values.service -}}
{{- if $service.create }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $service.labels)
      "annotations" (list .Values.commonAnnotations $service.annotations)
      "context" $) | nindent 2 }}
spec:
  selector: {{ include "common.labels.matchLabels" . | nindent 4 }}
  type: {{ $service.type }}
  {{- if $service.sessionAffinity }}
  sessionAffinity: {{ $service.sessionAffinity }}
  {{- end }}
  {{- if $service.sessionAffinityConfig }}
  sessionAffinityConfig: {{ $service.sessionAffinityConfig | toYaml | nindent 4 }}
  {{- end }}
  ports: {{ include "chc-lib.compute.listFromDict" (dict "values" $service.ports "keyName" "name" "context" $) | nindent 4 }}
{{- end }}
{{- end }}
