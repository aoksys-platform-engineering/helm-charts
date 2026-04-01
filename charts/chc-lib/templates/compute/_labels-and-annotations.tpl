{{/*
Helper function that returns a merged and templated labels/annotations section from a list of dicts
to use in the metadata sections of a template.

If empty input values are supplied, only standard labels are returned.

Provided dicts are merged and the last provided dict wins on duplicate keys.

Input scheme:
  dict:
    labels: list<dict<string, string>> (optional)
    annotations: list<dict<string, string>> (optional)
    context: object (has to be $)

Example template usage:
---
apiVersion: apps/v1
kind: Pod
metadata:
  name: test
  {{- include "chc-lib.compute.labels-and-annotations" (dict "context" $) | nindent 2 }}
...
spec:
  template: {{ include "chc-lib.compute.labels-and-annotations" (dict "context" $) | nindent 4 }}
  ...
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test
  {{- include "chc-lib.compute.labels-and-annotations" (dict "context" $) | nindent 2 }}
...
spec:
  template:
    secret:
      metadata:
        {{- include "chc-lib.compute.labels-and-annotations" (dict
          "labels" (list $.Values.commonLabels $v.secretLabels)
          "annotations" (list $.Values.commonAnnotations $v.secretAnnotations)
          "context" $) | nindent 8 }}
        ...
*/}}

{{- define "chc-lib.compute.labels-and-annotations" -}}
{{- $ctx := .context -}}
{{- $labels := include "common.tplvalues.merge" (dict "values" .labels "context" $ctx) | fromYaml -}}
labels: {{ include "common.labels.standard" (dict "customLabels" $labels "context" $ctx) | nindent 2 }}
{{- $annotations := include "common.tplvalues.merge" (dict "values" .annotations "context" $ctx) | fromYaml -}}
{{- if $annotations }}
annotations: {{ include "common.tplvalues.render" (dict "value" $annotations "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
