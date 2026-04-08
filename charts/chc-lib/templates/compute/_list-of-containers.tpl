{{/*
Helper function that returns an unordered list of containers based on "specs/_container.tpl".
Values go through tpl.

It's meant to be used in "specs/_pod.tpl".

Input scheme:
  dict:
    name: string
    values: dict
    context: object (has to be $)

Example input values:
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
      - until nc -z postgres.{{ .Release.Namespace }} 5432; do echo waiting for postgres; sleep 2; done
*/}}

{{- define "chc-lib.compute.list-of-containers" -}}
{{- $ctx := .context }}
{{- $results := list }}

{{- range $k, $v := .values }}
  {{- $entry := include "chc-lib.specs.container" (dict "name" $k "values" (omit $v "restartPolicy") "context" $ctx) | fromYaml -}}
  {{- $results = append $results $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($results | toYaml) "context" $ctx ) }}
{{- end }}
