{{- define "chc-lib.scaledobjects" }}
{{- $so := .Values.keda.scaledObjects -}}
{{- if and .Values.keda.enabled $so.create }}
{{- range $k, $v := $so.items }}
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $so.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $so.annotations $v.annotations)
      "context" $) | nindent 2 }}
spec:
  scaleTargetRef:
    {{- with ($v.scaleTargetRef).apiVersion }}
    apiVersion: {{ . }}
    {{- end }}
    {{- with ($v.scaleTargetRef).kind }}
    kind: {{ . }}
    {{- end }}
    name: {{ tpl (($v.scaleTargetRef).name | default $k) $ }}
    {{- $escn := (($v.scaleTargetRef).envSourceContainerName | default $so.envSourceContainerName) }}
    {{- with $escn }}
    envSourceContainerName: {{ tpl . $ }}
    {{- end }}

  {{- with $v.pollingInterval }}
  pollingInterval:  {{ . }}
  {{- end }}
  {{- with $v.cooldownPeriod }}
  cooldownPeriod: {{ . }}
  {{- end }}
  {{- with $v.initialCooldownPeriod }}
  initialCooldownPeriod: {{ . }}
  {{- end }}
  {{- with $v.idleReplicaCount }}
  idleReplicaCount: {{ . }}
  {{- end }}
  {{- with $v.minReplicaCount }}
  minReplicaCount: {{ . }}
  {{- end }}
  {{- with $v.maxReplicaCount }}
  maxReplicaCount: {{ . }}
  {{- end }}
  {{- if $v.fallback }}
  fallback: {{ include "common.tplvalues.render" (dict "value" $v.fallback "context" $) | nindent 4 }}
  {{- end }}
  {{- if $v.advanced }}
  advanced: {{ include "common.tplvalues.render" (dict "value" $v.advanced "context" $) | nindent 4 }}
  {{- end }}
  {{- if $v.triggers }}
  triggers: {{ include "common.tplvalues.render" (dict "value" $v.triggers "context" $) | nindent 4 }}
  {{- else }}
  triggers: {{ list | toYaml }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
