{{- define "chc-lib.statefulset" }}
{{- include "chc-lib.validations.deploymentXORstatefulset" . }}
{{- $statefulset := .Values.statefulset }}
{{- if $statefulset.create }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list .Values.commonLabels $statefulset.labels)
      "annotations" (list .Values.commonAnnotations $statefulset.annotations)
      "context" $) | nindent 2 }}
spec:
  minReadySeconds: {{ $statefulset.minReadySeconds }}
  podManagementPolicy: {{ $statefulset.podManagementPolicy }}
  {{- if not .Values.hpa.create }}
  replicas: {{ $statefulset.replicas }}
  {{- end }}
  revisionHistoryLimit: {{ $statefulset.revisionHistoryLimit }}
  serviceName: {{ include "common.names.fullname" . }}
  updateStrategy: {{ $statefulset.updateStrategy | toYaml | nindent 4 }}
  selector:
    matchLabels: {{ include "common.labels.matchLabels" . | nindent 6 }}

  volumeClaimTemplates: {{ include "common.tplvalues.render" (dict "value" $statefulset.volumeClaimTemplates "context" $) | nindent 4 }}
  persistentVolumeClaimRetentionPolicy: {{ $statefulset.persistentVolumeClaimRetentionPolicy | toYaml | nindent 4 }}

  template:
    metadata:
      {{- $configHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.configs.items "kind" "configs") | fromYaml -}}
      {{- $secretHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.secrets.items "kind" "secrets") | fromYaml -}}
      {{- include "chc-lib.render.labelsAnnotations" (dict
        "labels" (list .Values.commonLabels $statefulset.pods.labels)
        "annotations" (list .Values.commonAnnotations $statefulset.pods.annotations $configHashes $secretHashes)
        "context" $) | nindent 6 }}

    spec: {{ include "chc-lib.render.podSpec" (dict "values" $statefulset.pods "defaultRegistry" .Values.imageRegistry "context" $) | nindent 6 }}
{{- end }}
{{- end }}
