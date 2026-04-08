{{/*
Helper function that returns an ordered list of initContainers based on "specs/_container.tpl".
InitContainers are sorted by weight in descending order (largest value first) and all values go through tpl.

It's meant to be used in "specs/_pod.tpl".

Input scheme:
  dict:
    values: dict
    context: object (has to be $)

Example input values:
---
initContainers:
  echo:
    weight: 1
    image:
      repository: busybox
      tag: 1.28
    command: ["sh", "-c" , "echo 'hello world!'"]

  db-check:
    # Since 998 is greater than 1, this will be the first entry in the returned list
    weight: 998
    image:
      repository: busybox
      tag: 1.28
    command:
      - sh
      - -c
      - until nc -z postgres.{{ .Release.Namespace }} 5432; do echo waiting for postgres; sleep 2; done
*/}}

{{- define "chc-lib.compute.list-of-init-containers" -}}
{{- $ctx := .context }}
{{- $results := dict }}
{{- $sortedResults := list }}

{{- range $k, $v := .values }}
  {{- if or (lt (int $v.weight) 1) (gt (int $v.weight) 999) }}
    {{- fail (printf "The initContainer '%v' has an invalid weight value of '%v' (must be >0 and <= 999)" $k $v.weight) }}
  {{- end }}
  {{- $weight := printf "%03d" (int $v.weight) }}
  {{- $entry := include "chc-lib.specs.container" (dict "name" $k "values" (omit $v "weight" "lifecycle" "startupProbe" "livenessProbe" "readinessProbe") "context" $ctx) | fromYaml -}}
  {{- $results = merge $results (dict $weight $entry) -}}
{{- end }}

{{- range $results }}
  {{- $sortedResults = prepend $sortedResults . }}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($sortedResults | toYaml) "context" $ctx ) }}
{{- end }}
