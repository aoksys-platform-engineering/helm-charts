{{/*
Returns a podSpec to use in all templates that manage pods (deployment, statefulset, job, cronjob, etc.).
The podSpec itself relies on "_containerSpec.tpl", beause (init-)containers are part of every pod.

See https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec for more.

input scheme:
  dict:
    values: dict
    context: object (global chart context, has to be $)

Example template usage:
---
apiVersion: v1
kind: Pod
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec: {{ include "chc-lib.render.podSpec" (dict "values" .Values.pod "context" $) | nindent 2 }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec:
  template:
    metadata: {{ include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 4 }}
    spec: {{ include "chc-lib.render.podSpec" (dict "values" .Values.deployment.pods "context" $) | nindent 4 }}

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec:
  template:
    metadata: {{ include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 4 }}
    spec: {{ include "chc-lib.render.podSpec" (dict "values" .Values.statefulset.pods "context" $) | nindent 4 }}
*/}}

{{- define "chc-lib.render.podSpec" -}}
{{- $ctx := .context -}}

restartPolicy: {{ (.values).restartPolicy | default "Always" }}
securityContext: {{ include "chc-lib.compute.podSecurityContext" (dict "values" (.values).securityContext) | nindent 2 }}
{{- with (.values).imagePullSecrets }}
imagePullSecrets: {{ . | toYaml | nindent 2 }}
{{- end }}
serviceAccountName: {{ include "chc-lib.compute.serviceAccountName" $ctx }}
{{- with (.values).priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with (.values).terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- with (.values).nodeSelector }}
nodeSelector: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- with (.values).tolerations }}
tolerations: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- if (.values).hostNetwork }}
hostNetwork: true
{{- end }}
{{- with (.values).dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with (.values).hostAliases }}
hostAliases: {{ . | toYaml | nindent 2 }}
{{- end }}

{{- if (.values).volumes }}
volumes: {{ include "chc-lib.compute.listFromDict" (dict "values" .values.volumes "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}

{{- $a := (.values).affinity }}
{{- if or $a.podAffinity $a.podAntiAffinity $a.nodeAffinity }}
affinity:
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
  {{- if $a.nodeAffinity }}
  nodeAffinity: {{ include "common.tplvalues.render" (dict "value" $a.nodeAffinity "context" $ctx) | nindent 4 }}
  {{- end }}
{{- end }}

{{- if (.values).initContainers }}
initContainers: {{ include "chc-lib.compute.initContainers" (dict "values" .values.initContainers "context" $ctx) | nindent 2 }}      
{{- end }}

containers: {{ include "chc-lib.compute.containers" (dict "values" (.values).containers "context" $ctx) | nindent 2 }}
{{- end }}
