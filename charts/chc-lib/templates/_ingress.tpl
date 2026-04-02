{{/*
Template to generate an "Ingress" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#ingress-v1-networking-k8s-io" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.ingress.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
{{- if and (empty .values.defaultBackend) (empty .values.rules) }}
{{- fail "Both 'defaultBackend' and 'rules' are nil or empty, but at least of one them must be set" }}
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  {{- if .values.defaultBackend }}
  defaultBackend: {{ .values.defaultBackend }}
  {{- end }}
  {{- if .values.className }}
  ingressClassName: {{ .values.className }}
  {{- end }}
  rules: {{ include "common.tplvalues.render" (dict "value" .values.rules "context" $ctx) | nindent 4 }}
  {{- if .values.tls }}
  tls: {{ include "common.tplvalues.render" (dict "value" .values.tls "context" $ctx) | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
