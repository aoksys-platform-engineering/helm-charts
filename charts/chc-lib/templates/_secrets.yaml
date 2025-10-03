{{- define "chc-lib.secrets" }}
{{- $secrets := .Values.secrets }}
{{- if $secrets.create }}
{{- range $k, $v := $secrets.items }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $v.namespaceOverride | default $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $secrets.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $secrets.annotations $v.annotations)
      "context" $) | nindent 2 }}
stringData: {{ include "common.tplvalues.render" (dict "value" $v.data "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
