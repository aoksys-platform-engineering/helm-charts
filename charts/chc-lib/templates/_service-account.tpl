{{/*
Template to generate a "ServiceAccount" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#serviceaccount-v1-core" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.service-account.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
{{- if not (and .values.create (ne .values.name "default")) }}
{{- fail "If 'create=true', the 'name' of the serviceAccount cannot be 'default'" }}
{{- end }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
{{- if .values.automountToken }}
automountServiceAccountToken: {{ .values.automountToken }}
{{- end }}
{{- end }}
{{- end }}
