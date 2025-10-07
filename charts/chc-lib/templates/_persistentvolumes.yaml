{{- define "chc-lib.persistentvolumes" }}
{{- $pvs := .Values.persistentVolumes }}
{{- if $pvs.create }}
{{- range $k, $v := $pvs.items }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ tpl $k $ }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $pvs.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $pvs.annotations $v.annotations)
      "context" $) | nindent 2 }}
spec: {{ include "common.tplvalues.render" (dict "value" $v.spec "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
