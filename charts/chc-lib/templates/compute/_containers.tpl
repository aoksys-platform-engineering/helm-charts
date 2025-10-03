{{/*
Returns a list of containers to be used in a PodSpec of a PodTemplate.
This helper is meant to be used in "_podSpec.tpl".

Input scheme:
  dict:
    name: string
    values: dict
    context: object (global chart context, has to be $)

Example values:
---
containers:
  echo:
    image:
      repository: busybox
      tag: 1.28

    command: ["sh", "-c" , "echo 'hello world!'"]

  db-check:
    image:
      repository: busybox
      tag: 1.28

    command:
      - sh
      - -c
      # All values for each initContainer are templated, so expressions like {{ .Release.Namespace }} can be used
      - until nc -z postgres.{{ .Release.Namespace }} 5432; do echo waiting for postgres; sleep 2; done
*/}}

{{- define "chc-lib.compute.containers" -}}
{{- $ctx := .context }}
{{- $results := list }}

{{- range $k, $v := .values }}
  {{- $entry := include "chc-lib.render.containerSpec" (dict "name" $k "values" $v "context" $ctx) | fromYaml -}}
  {{- $results = append $results $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($results | toYaml) "context" $ctx ) }}
{{- end }}
