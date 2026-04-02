{{/*
Template to generate an "ExternalSecret" manifest from.

See "https://external-secrets.io/latest/api/spec/#external-secrets.io/v1.ExternalSecretSpec" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.external-secret.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values "context" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  {{- if .values.refreshPolicy }}
  refreshPolicy: {{ .values.refreshPolicy }}
  {{- end }}

  refreshInterval: {{ .values.refreshInterval }}
  secretStoreRef:
    name: {{ .values.secretStoreRef.name }}
    kind: {{ .values.secretStoreRef.kind }}
  
  target:
    name: {{ include "chc-lib.compute.name" (dict "name" .name "values" .values.secret "context" $ctx) }}
    {{- if .values.secret.creationPolicy }}
    creationPolicy: {{ .values.secret.creationPolicy }}
    {{- end }}
    {{- if .values.secret.deletionPolicy }}
    deletionPolicy: {{ .values.secret.deletionPolicy }}
    {{- end }}
    template:
      {{- if .values.secret.type }}
      type: {{ .values.secret.type }}
      {{- end }}
      metadata:
        {{- include "chc-lib.compute.labels-and-annotations" (dict
            "labels" (list $ctx.Values.commonLabels .values.secret.labels)
            "annotations" (list $ctx.Values.commonAnnotations .values.secret.annotations)
            "context" $ctx) | nindent 8 }}

  {{- if .values.data }}
  {{- /* Set vars to use for defaults here to avoid scoping issues inside "range" loop */ -}}
  {{- $basePath := .values.basePath }}
  {{- $decodingStrategy := .values.decodingStrategy }}
  {{- $conversionStrategy := .values.conversionStrategy }}
  {{- $metadataPolicy := .values.metadataPolicy }}
  data:
    {{- range .values.data }}
    - secretKey: {{ .secretKey }}
      remoteRef:
        {{- $key := .remoteRef.key }}
        {{- if ne $basePath "" }}
        {{- $key = printf "%s/%s" $basePath $key | replace "//" "/" }}
        {{- end }}
        key: {{ $key }}
        {{- if .remoteRef.property }}
        property: {{ .remoteRef.property }}
        {{- end }}
        decodingStrategy: {{ .remoteRef.decodingStrategy | default $decodingStrategy }}
        conversionStrategy: {{ .remoteRef.conversionStrategy | default $conversionStrategy }}
        metadataPolicy: {{ .remoteRef.metadataPolicy | default $metadataPolicy }}
    {{- end }}
  {{- else }}
  data: {{ list | toYaml }}
  {{- end }}
{{- end }}
{{- end }}
