{{- define "chc-lib.persistentvolumeclaims" }}
{{- $pvcs := .Values.persistentVolumeClaims }}
{{- if $pvcs.create }}
{{- range $k, $v := $pvcs.items }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $pvcs.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $pvcs.annotations $v.annotations)
      "context" $) | nindent 2 }}
spec: {{ include "common.tplvalues.render" (dict "value" $v.spec "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
