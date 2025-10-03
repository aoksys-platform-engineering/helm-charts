{{/*
Returns merged and templated labels/annotations to use in metadata sections of a template.
If no inputs are supplied, only standard labels are returned.

NOTE: Always provide the most generic labels/annotations first, because the last provided will win on a merge.

input scheme:
  dict:
    labels: list<dict<string, string>> (optional)
    annotations: list<dict<string, string>> (optional)
    context: object (global chart context, has to be $)

Example template usage:
---
apiVersion: apps/v1
kind: Pod
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec:
  template: {{ include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 4 }}
  ...
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec:
  secretTemplate: {{ include "chc-lib.render.labelsAnnotations" (dict "labels" (list $.Values.commonLabels $v.secretLabels) "context" $) | nindent 4 }}
  ...
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test
  {{- include "chc-lib.render.labelsAnnotations" (dict "context" $) | nindent 2 }}
...
spec:
  template:
    secret:
      metadata:
        {{- include "chc-lib.render.labelsAnnotations" (dict
          "labels" (list $.Values.commonLabels $v.secretLabels)
          "annotations" (list $.Values.commonAnnotations $v.secretAnnotations)
          "context" $) | nindent 8 }}
        ...
*/}}

{{- define "chc-lib.render.labelsAnnotations" -}}
{{- $ctx := .context -}}
{{- $labels := include "common.tplvalues.merge" (dict "values" .labels "context" $ctx) | fromYaml -}}
labels: {{ include "common.labels.standard" (dict "customLabels" $labels "context" $ctx) | nindent 2 }}
{{- $annotations := include "common.tplvalues.merge" (dict "values" .annotations "context" $ctx) | fromYaml -}}
{{- if $annotations }}
annotations: {{ include "common.tplvalues.render" (dict "value" $annotations "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
