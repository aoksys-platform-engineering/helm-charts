{{/*
Template to generate a "RoleBinding" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#rolebinding-v1-rbac-authorization-k8s-io" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.role-binding.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ .name | default (include "common.names.fullname" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
subjects:
  - kind: {{ .values.subject.kind }}
    name: {{ .values.subject.name | default (include "common.names.fullname" $ctx) }}
    namespace: {{ .values.subject.namespace | default $ctx.Release.Namespace }}
roleRef:
  apiGroup: {{ .values.roleRef.apiGroup }}
  kind: {{ .values.roleRef.kind }}
  name: {{ .values.roleRef.name | default (include "common.names.fullname" $ctx) }}
{{- end }}
{{- end }}
