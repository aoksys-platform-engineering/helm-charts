{{/*
Template to generate a "PodDisruptionBudget" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#poddisruptionbudget-v1-policy" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.pod-disruption-budget.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
{{- if and (empty .values.maxUnavailable) (empty .values.minAvailable) }}
{{- fail "Both 'minAvailable' and 'maxUnavailable' are nil or empty, but at least of one them must be set" }}
{{- end }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  selector:
    matchLabels: {{ include "common.labels.matchLabels" $ctx | nindent 6 }}

  {{- if .values.unhealthyPodEvictionPolicy }}
  unhealthyPodEvictionPolicy: {{ .values.unhealthyPodEvictionPolicy }}
  {{- end }}
  {{- if .values.maxUnavailable }}
  maxUnavailable: {{ .values.maxUnavailable }}
  {{- else }}
  minAvailable: {{ .values.minAvailable }}
  {{- end }}
{{- end }}
{{- end }}
