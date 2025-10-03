{{/*
Returns a list of initContainers to be used in a PodSpec of a PodTemplate.
Values are sorted by weight in descending order (largest value first) and all key/values are templated.

This helper is meant to be used in "_podSpec.tpl".

Input scheme:
  dict:
    values: dict
    context: object (global chart context, has to be $)

Example values:
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
      # All values for each initContainer are templated, so expressions like {{ .Release.Namespace }} can be used
      - until nc -z postgres.{{ .Release.Namespace }} 5432; do echo waiting for postgres; sleep 2; done

Example usage:
---
initContainers: {{ include "chc-lib.compute.initContainers" (dict "values" .Values.deployment.initContainers "context" $) | nindent 2 }}
...
*/}}

{{- define "chc-lib.compute.initContainers" -}}
{{- $ctx := .context }}
{{- $results := dict }}
{{- $sortedResults := list }}

{{- range $k, $v := .values }}
  {{- if or (lt (int $v.weight) 1) (gt (int $v.weight) 999) }}
    {{- fail (printf "The initContainer '%v' has an invalid weight value of '%v' (must be >0 and <= 999)" $k $v.weight) }}
  {{- end }}
  {{- $weight := printf "%03d" (int $v.weight) }}
  {{- $entry := include "chc-lib.render.containerSpec" (dict "name" $k "values" (omit $v "weight") "context" $ctx) | fromYaml -}}
  {{- $results = merge $results (dict $weight $entry) -}}
{{- end }}

{{- range $results }}
  {{- $sortedResults = prepend $sortedResults . }}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($sortedResults | toYaml) "context" $ctx ) }}
{{- end }}
