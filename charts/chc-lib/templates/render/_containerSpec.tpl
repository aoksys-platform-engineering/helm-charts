{{/*
Returns a templated containerSpec to use in various parts of a PodSpec.
This helper is not meant to be used directly in a template but only as part of other tpl scripts like
"_podSpec.tpl" or "_initContainers.tpl".

See https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container for more.

input scheme:
  dict:
    name: string
    values: dict
    context: object (global chart context, has to be $)
*/}}

{{- define "chc-lib.render.containerSpec" -}}
{{- $ctx := .context -}}

name: {{ .name }}
image: {{ include "chc-lib.compute.image" (dict "values" .values.image "context" $ctx) }}
{{- with (.values.image).pullPolicy }}
imagePullPolicy: {{ . }}
{{- end }}
{{- with (.values).command }}
command: {{ include "common.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with (.values).args }}
args: {{ include "common.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
securityContext: {{ include "chc-lib.compute.containerSecurityContext" (dict "values" (.values).securityContext) | nindent 2 }}
{{- with (.values).restartPolicy }}
restartPolicy: {{ . }}
{{- end }}
resources: {{ include "chc-lib.compute.resources" (dict "values" (.values).resources) | nindent 2 }}
{{- if .values.volumeMounts }}
volumeMounts: {{ include "chc-lib.compute.listFromDict" (dict "values" .values.volumeMounts "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.env }}
env: {{ include "chc-lib.compute.envFromDict" (dict "values" .values.env "context" $ctx) | nindent 2 }}
{{- end }}
{{- with (.values).ports }}
ports: {{ include "chc-lib.compute.listFromDict" (dict "values" . "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- with .values.startupProbe }}
startupProbe: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- with .values.livenessProbe }}
livenessProbe: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- with .values.readinessProbe }}
readinessProbe: {{ . | toYaml | nindent 2 }}
{{- end }}

{{- end }}
