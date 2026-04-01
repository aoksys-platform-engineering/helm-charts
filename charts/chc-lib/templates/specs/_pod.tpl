{{/*
Contains all key/values that can be used to configure a "pod".

Its used in all templates that manage pods (deployments, statefulsets, jobs, cronjobs, etc.).
This spec relies on "specs/_container.tpl" because (init-)containers are part of every pod.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#pod-v1-core" for the full API spec.

input scheme:
  dict:
    values: dict
    context: object (has to be $)

Example template usage:
---
apiVersion: v1
kind: Pod
metadata:
  name: test
  ...
spec: {{ include "chc-lib.specs.pod" (dict "values" .Values.pod "context" $) | nindent 2 }}
*/}}

{{- define "chc-lib.specs.pod" -}}
{{- $ctx := .context -}}

{{- if .values.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ .values.activeDeadlineSeconds }}
{{- end }}
{{- $a := (.values).affinity }}
{{- if or $a.podAffinity $a.podAntiAffinity $a.nodeAffinity }}
affinity:
  {{- if $a.nodeAffinity }}
  nodeAffinity: {{ include "common.tplvalues.render" (dict "value" $a.nodeAffinity "context" $ctx) | nindent 4 }}
  {{- end }}
  {{- if kindIs "string" $a.podAffinity }}
  podAffinity: {{ include "common.affinities.pods" (dict "type" $a.podAffinity "customLabels" (include "common.labels.matchLabels" $ctx) "context" $ctx) | nindent 4 }}
  {{- else if gt (len $a.podAffinity) 0 }}
  podAffinity: {{ $a.podAffinity | toYaml | nindent 4 }}
  {{- end }}
  {{- if kindIs "string" $a.podAntiAffinity }}
  podAntiAffinity: {{ include "common.affinities.pods" (dict "type" $a.podAntiAffinity "customLabels" (include "common.labels.matchLabels" $ctx) "context" $ctx) | nindent 4 }}
  {{- else if gt (len $a.podAntiAffinity) 0 }}
  podAntiAffinity: {{ $a.podAntiAffinity | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
{{- if .values.automountServiceAccountToken }}
automountServiceAccountToken: true
{{- end }}
containers: {{ include "chc-lib.compute.list-of-containers" (dict "values" .values.containers "context" $ctx) | nindent 2 }}
{{- if .values.dnsPolicy }}
dnsPolicy: {{ .values.dnsPolicy }}
{{- end }}
{{- with .values.hostAliases }}
hostAliases: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- if .values.hostNetwork }}
hostNetwork: true
{{- end }}
{{- with .values.imagePullSecrets }}
imagePullSecrets: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- if .values.initContainers }}
initContainers: {{ include "chc-lib.compute.list-of-init-containers" (dict "values" .values.initContainers "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.nodeName }}
nodeName: {{ .values.nodeName }}
{{- end }}
{{- with .values.nodeSelector }}
nodeSelector: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- if .values.priorityClassName }}
priorityClassName: {{ .values.priorityClassName }}
{{- end }}
{{- if .values.restartPolicy }}
restartPolicy: {{ .values.restartPolicy }}
{{- end }}
securityContext: {{ include "chc-lib.compute.pod-security-context" (dict "values" (.values).securityContext) | nindent 2 }}
serviceAccountName: {{ .values.serviceAccountName }}
{{- if .values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .values.terminationGracePeriodSeconds }}
{{- end }}
{{- with .values.tolerations }}
tolerations: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- if .values.volumes }}
volumes: {{ include "chc-lib.compute.list-from-dict" (dict "values" .values.volumes "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
