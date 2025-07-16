{{/*
Create the name of the serviceAccount to use.

Example template usage:
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "chc-lib.helpers.serviceAccountName" . }}
  ...
---
apiVersion: v1
kind: Deployment
...
spec:
  template:
    serviceAccountName: {{ include "chc-lib.helpers.serviceAccountName" . | nindent 6 }}
*/}}

{{- define "chc-lib.helpers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
