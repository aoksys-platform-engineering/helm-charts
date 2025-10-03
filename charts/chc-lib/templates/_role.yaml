{{- define "chc-lib.role" }}
{{- $role := .Values.rbac.role -}}
{{- if and .Values.serviceAccount.create .Values.rbac.create }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Values.rbac.namespaceOverride | default .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $role.labels)
      "annotations" (list .Values.commonAnnotations $role.annotations)
      "context" $) | nindent 2 }}
rules: {{ include "common.tplvalues.render" (dict "value" $role.rules "context" $) | nindent 2 }}
{{- end }}
{{- end }}
