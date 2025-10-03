{{- define "chc-lib.hpa" }}
{{- include "chc-lib.validations.deploymentXORstatefulset" . }}
{{- $hpa := .Values.hpa -}}
{{- if $hpa.create }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $hpa.labels)
      "annotations" (list .Values.commonAnnotations $hpa.annotations)
      "context" $) | nindent 2 }}
spec:
  minReplicas: {{ $hpa.minReplicas }}
  maxReplicas: {{ $hpa.maxReplicas }}
  scaleTargetRef:
    apiVersion: apps/v1
    name: {{ include "common.names.fullname" . }}
    {{- if .Values.deployment.create }}
    kind: Deployment
    {{- else if .Values.statefulset.create }}
    kind: StatefulSet
    {{- end }}

  metrics:
    {{- if $hpa.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $hpa.targetCPUUtilizationPercentage }}
    {{- end }}

    {{- if $hpa.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $hpa.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- end }}
