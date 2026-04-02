{{/*
Helper function that computes and returns the name for a resource.

Input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)

Example template usage:
---
apiVersion: v1
kind: Pod
metadata:
  name {{ include "chc-lib.compute.name" (dict "values" .Values.pod "context" $) }}
...
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ include "chc-lib.compute.name" (dict "values" .Values.externalSecret "context" $) }}
  ...
spec:
  ...
  target:
    name: {{ include "chc-lib.compute.name" (dict "values" .Values.externalSecret.secret "context" $) }}
    ...
*/}}

{{- define "chc-lib.compute.name" -}}
{{- if .values.name }}
  {{- tpl .values.name .context }}
{{- else if .name }}
  {{- tpl .name .context }}
{{- else }}
  {{- include "common.names.fullname" .context }}
{{- end }}
{{- end }}
