{{- define "chc-lib.pdb" }}
{{- $pdb := .Values.pdb -}}
{{- if $pdb.create }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $pdb.labels)
      "annotations" (list .Values.commonAnnotations $pdb.annotations)
      "context" $) | nindent 2 }}
spec:
  selector:
    matchLabels: {{ include "common.labels.matchLabels" . | nindent 6 }}

  {{- if $pdb.minAvailable }}
  minAvailable: {{ $pdb.minAvailable }}
  {{- else }}
  maxUnavailable: {{ $pdb.maxUnavailable }}
  {{- end }}
{{- end }}
{{- end }}
