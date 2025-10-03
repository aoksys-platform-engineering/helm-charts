{{- define "chc-lib.serviceaccount" }}
{{- $serviceaccount := .Values.serviceAccount -}}
{{- if $serviceaccount.create }}
---
apiVersion: v1
kind: ServiceAccount
automountServiceAccountToken: {{ $serviceaccount.automountServiceAccountToken }}
metadata:
  name: {{ include "chc-lib.compute.serviceAccountName" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $serviceaccount.labels)
      "annotations" (list .Values.commonAnnotations $serviceaccount.annotations)
      "context" $) | nindent 2 }}
{{- end }}
{{- end }}
