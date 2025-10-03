{{- define "chc-lib.configmaps" }}
{{- $configs := .Values.configs }}
{{- if $configs.create }}
{{- range $k, $v := $configs.items }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $v.namespaceOverride | default $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $configs.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $configs.annotations $v.annotations)
      "context" $) | nindent 2 }}
data: {{ include "common.tplvalues.render" (dict "value" $v.data "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
