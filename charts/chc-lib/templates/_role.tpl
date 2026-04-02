{{/*
Template to generate a "Role" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#role-v1-rbac-authorization-k8s-io" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.role.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
rules: {{ include "common.tplvalues.render" (dict "value" .values.rules "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
