{{- define "chc-lib.rolebinding" }}
{{- $rolebinding := .Values.rbac.roleBinding -}}
{{- if and .Values.serviceAccount.create .Values.rbac.create }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Values.rbac.namespaceOverride | default .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $rolebinding.labels)
      "annotations" (list .Values.commonAnnotations $rolebinding.annotations)
      "context" $) | nindent 2 }}
subjects:
  - kind: ServiceAccount
    name: {{ include "chc-lib.compute.serviceAccountName" . }}
    namespace: {{ .Release.Namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "common.names.fullname" . }}
{{- end }}
{{- end }}
