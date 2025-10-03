{{/*
Helper script to determine if any key/value pair in a secret or config item has "restartPodsOnChange=true" at "values" set.
If true, key/value pairs are added to a dict containing the key and the checksum of the data which can be used
to annotate pods using "chc-lib.render.labelsAnnotations" to automatically roll pods when the data fields of secret ot config items have changed.

Note that this doesn't work on resources that are created and managed by an operator at runtime,
e.g. the secret created from a "certificate" managed by "cert-manager".

This helper is meant to be used in the metadata section of a PodTemplate, like in a deployment or similar.

Input scheme:
  dict:
    values: dict
    kind: string (can be "secret" or "configs")

Example values:
---
configs:
  app-configs:
    restartPodsOnChange: true
    data:
      example: value

secrets:
  app-secrets:
    restartPodsOnChange: false
    data:
      example: value

Example usage:
---
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    metadata:
      {{- $configHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.configs.items "kind" "configs") | fromYaml }}
      {{- $secretHashes := include "chc-lib.compute.restartPodsOnChange" (dict "values" .Values.secrets.items "kind" "secrets") | fromYaml }}
      {{- include "chc-lib.render.labelsAnnotations" (dict
        "labels" (list .Values.deployment.podLabels .Values.commonLabels)
        "annotations" (list .Values.deployment.podAnnotations .Values.commonAnnotations $configHashes $secretHashes)
        "context" $) | nindent 6 }}
    ...
*/}}

{{- define "chc-lib.compute.restartPodsOnChange" -}}
{{- $hashesRequired := dict "val" false "items" (dict) -}}
{{- $hashAnnotations := dict }}
{{- $kPrefix := ternary "checksum/configmap" "checksum/secret" (eq .kind "configs") -}}

{{- range $k, $v := .values }}
  {{- $isBool := kindIs "bool" $v.restartPodsOnChange }}
  {{- if and $isBool $v.restartPodsOnChange }}
    {{- $_ := set $hashesRequired "val" true }}
    {{- $_ := set $hashesRequired.items $k (sha256sum (toYaml $v.data)) }}
  {{- end }}
{{- end }}

{{- if and $hashesRequired.val $hashesRequired.items }}
  {{- range $k, $v := $hashesRequired.items }}
    {{- $_ := set $hashAnnotations (printf "%s-%s" $kPrefix $k) $v }}
  {{- end }}
{{- end }}

{{- $hashAnnotations | toYaml }}
{{- end }}
