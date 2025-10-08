{{- define "chc-lib.deployment" }}
{{- include "chc-lib.validations.deploymentXORstatefulset" . }}
{{- $deployment := .Values.deployment }}
{{- if $deployment.create }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $deployment.labels)
      "annotations" (list .Values.commonAnnotations $deployment.annotations)
      "context" $) | nindent 2 }}
spec:
  {{- if not .Values.hpa.create }}
  replicas: {{ $deployment.replicas }}
  {{- end }}
  strategy: {{ $deployment.updateStrategy | toYaml | nindent 4 }}
  revisionHistoryLimit: {{ $deployment.revisionHistoryLimit }}
  selector:
    matchLabels: {{ include "common.labels.matchLabels" . | nindent 6 }}

  template:
    metadata:
      {{- $configHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.configs.items "kind" "configs") | fromYaml -}}
      {{- $secretHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.secrets.items "kind" "secrets") | fromYaml -}}
      {{- include "chc-lib.render.labelsAnnotations" (dict
        "labels" (list .Values.commonLabels $deployment.pods.labels)
        "annotations" (list .Values.commonAnnotations $deployment.pods.annotations $configHashes $secretHashes)
        "context" $) | nindent 6 }}

    spec: {{ include "chc-lib.render.podSpec" (dict "values" $deployment.pods "defaultRegistry" .Values.imageRegistry "context" $) | nindent 6 }}
{{- end }}
{{- end }}
