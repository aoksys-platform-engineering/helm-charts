{{/*
Contains all key/values that can be used to configure a "container".

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#container-v1-core" for the full API spec.

input scheme:
  dict:
    name: string
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.specs.container" -}}
{{- $ctx := .context -}}

name: {{ .name }}
image: {{ include "chc-lib.compute.image-pull-string" (dict "values" .values.image "context" $ctx) }}
{{- with (.values.image).pullPolicy }}
imagePullPolicy: {{ . }}
{{- end }}
{{- with (.values).command }}
command: {{ include "common.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with (.values).args }}
args: {{ include "common.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
securityContext: {{ include "chc-lib.compute.container-security-context" (dict "values" (.values).securityContext) | nindent 2 }}
{{- with (.values).restartPolicy }}
restartPolicy: {{ . }}
{{- end }}
resources: {{ include "chc-lib.compute.container-resources" (dict "values" .values.resources) | nindent 2 }}
{{- if .values.volumeMounts }}
volumeMounts: {{ include "chc-lib.compute.list-from-dict" (dict "values" .values.volumeMounts "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.env }}
env: {{ include "chc-lib.compute.env-from-dict" (dict "values" .values.env "context" $ctx) | nindent 2 }}
{{- end }}
{{- with (.values).ports }}
ports: {{ include "chc-lib.compute.list-from-dict" (dict "values" . "keyName" "name" "context" $ctx) | nindent 2 }}
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
