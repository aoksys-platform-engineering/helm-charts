{{/*
Helper function that returns a list of dicts to use in the env spec of a container.
All values go through tpl.

This helper is meant to be used in "specs/_container.tpl".

Input scheme:
  dict:
    values: dict
    context: object (has to be $)

Example input values:
---
env:
  LOG_LEVEL: debug
  SERVICE_NAME: "{{ .Release.Name }}"
  SPECIAL_LEVEL_KEY:
    valueFrom:
      configMapKeyRef:
        name: "{{ .Release.Name }}-config"
        key: special.how
*/}}

{{- define "chc-lib.compute.env-from-dict" -}}
{{- $result := list }}

{{- range $k, $v := .values }}
  {{- $entry := dict "name" $k -}}
  {{- if kindIs "map" $v }}
    {{- $entry = merge $entry $v -}}
  {{- else }}
    {{- $entry = merge $entry (dict "value" ($v | toString)) -}}
  {{- end }}
  {{- $result = append $result $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($result | toYaml) "context" .context) }}
{{- end }}
