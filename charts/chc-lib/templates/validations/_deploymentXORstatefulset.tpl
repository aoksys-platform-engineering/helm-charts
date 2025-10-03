{{/*
Validator that fails if both ".Values.deployment.create" and ".Values.statefulset.create" are "true".
Useful for all templates where if/else statements depend on those values, like the deployment and hpa templates.

Example usage:

{{- define "chc-lib.hpa" }}
{{- include "chc-lib.validations.deploymentXORstatefulset" . }}
...
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
...
---
{{- define "chc-lib.deployment" }}
{{- include "chc-lib.validations.deploymentXORstatefulset" . }}
apiVersion: v1
kind: Deployment
...
*/}}

{{- define "chc-lib.validations.deploymentXORstatefulset" }}
{{- if and .Values.deployment.create .Values.statefulset.create }}
{{ fail "Only one of '.Values.deployment.create' and '.Values.statefulset.create' can be 'true' at the same time. They are mutually exclusive." }}
{{- end }}
{{- end }}
