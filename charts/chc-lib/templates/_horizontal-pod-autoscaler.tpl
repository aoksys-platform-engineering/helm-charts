{{/*
Template to generate a "HorizontalPodAutoscaler" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#horizontalpodautoscalerspec-v2-autoscaling" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.horizontal-pod-autoscaler.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
{{- if and (empty .values.targetCPUUtilizationPercentage) (empty .values.targetMemoryUtilizationPercentage) }}
{{- fail "Both 'targetCPUUtilizationPercentage' and 'targetMemoryUtilizationPercentage' are nil or empty, but at least of one them must be set" }}
{{- end }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  minReplicas: {{ .values.minReplicas }}
  maxReplicas: {{ .values.maxReplicas }}
  scaleTargetRef:
    apiVersion: {{ .values.scaleTargetRef.apiVersion }}
    kind: {{ .values.scaleTargetRef.kind }}
    name: {{ .values.scaleTargetRef.name | default (include "common.names.fullname" $ctx) }}

  {{- if .values.behavior }}
  behavior: {{ .values.behavior | toYaml | nindent 4 }}
  {{- end }}

  metrics:
    {{- if .values.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .values.targetCPUUtilizationPercentage }}
    {{- end }}

    {{- if .values.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .values.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- end }}
