{{/*
Template to generate a "ReferenceGrant" manifest from.

See "https://gateway-api.sigs.k8s.io/api-types/referencegrant/#referencegrant" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.reference-grant.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ .values.namespaceOverride | default $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec: {{ include "common.tplvalues.render" (dict "value" .values.spec "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
