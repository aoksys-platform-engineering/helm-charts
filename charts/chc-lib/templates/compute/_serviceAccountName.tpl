{{/*
Generates the name for a serviceAccount.

Example usage:
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "chc-lib.compute.serviceAccountName" . }}
  ...
---
apiVersion: v1
kind: Deployment
...
spec:
  template:
    serviceAccountName: {{ include "chc-lib.compute.serviceAccountName" . | nindent 6 }}
*/}}

{{- define "chc-lib.compute.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
  {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
