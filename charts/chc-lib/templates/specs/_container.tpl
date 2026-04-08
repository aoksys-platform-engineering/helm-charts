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
image: {{ include "chc-lib.compute.image-pull-string" (dict "name" .name "values" .values.image "context" $ctx) }}
{{- if (.values.image).pullPolicy }}
imagePullPolicy: {{ .values.image.pullPolicy }}
{{- end }}
{{- if .values.command }}
command: {{ include "common.tplvalues.render" (dict "value" .values.command "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.args }}
args: {{ include "common.tplvalues.render" (dict "value" .values.args "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.workingDir }}
workingDir: {{ .values.workingDir }}
{{- end }}
securityContext: {{ include "chc-lib.compute.container-security-context" (dict "values" (.values).securityContext) | nindent 2 }}
{{- if .values.restartPolicy }}
restartPolicy: {{ .values.restartPolicy }}
{{- end }}
resources: {{ include "chc-lib.compute.container-resources" (dict "values" .values.resources) | nindent 2 }}
{{- if .values.volumeMounts }}
volumeMounts: {{ include "chc-lib.compute.list-from-dict" (dict "values" .values.volumeMounts "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.env }}
env: {{ include "chc-lib.compute.env-from-dict" (dict "values" .values.env "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.ports }}
ports: {{ include "chc-lib.compute.list-from-dict" (dict "values" .values.ports "keyName" "name" "context" $ctx) | nindent 2 }}
{{- end }}
{{- if .values.lifecycle }}
lifecycle: {{ .values.lifecycle | toYaml | nindent 2 }}
{{- end }}
{{- if .values.startupProbe }}
startupProbe: {{ .values.startupProbe | toYaml | nindent 2 }}
{{- end }}
{{- if .values.livenessProbe }}
livenessProbe: {{ .values.livenessProbe | toYaml | nindent 2 }}
{{- end }}
{{- if .values.readinessProbe }}
readinessProbe: {{ .values.readinessProbe | toYaml | nindent 2 }}
{{- end }}
{{- end }}
