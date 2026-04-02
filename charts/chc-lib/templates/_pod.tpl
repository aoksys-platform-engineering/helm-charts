{{/*
Template to generate a "Pod" manifest from.

See "https://kubernetes.io/docs/reference/generated/kubernetes-api/latest/#pod-v1-core" for the full API spec.

NOTE: The main purpose of this template is to provide an easy to use, small interface to run unittests against.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.pod.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}

{{- /* We use "mergeOverwrite" and "deepCopy" here to ensure chc-lib default values are always applied but not modified */}}
spec: {{ include "chc-lib.specs.pod" (dict "values" (mergeOverwrite (deepCopy $ctx.Values.pod) .values) "defaultRegistry" $ctx.Values.imageRegistry "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
