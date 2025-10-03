{{/*
Returns a container image string to be used for a container. If no registry is provided, only the repository name is used.

This helper is meant to be used in "_containerSpec.tpl".

Input scheme:
  dict:
    values:
      registry: string|nil
      repository: string
      tag: string|nil (default: .Chart.AppVersion)
      digest: string|nil

    context: object (global chart context, has to be $)

Example values:
---
image:
  registry: docker-hosted.central.aws.aok-systems.de
  repository: occonnect/soe-service
  tag: ~ # .Chart.AppVersion will be used
  digest: ~

OR

image:
  registry: docker-hosted.central.aws.aok-systems.de
  repository: occonnect/soe-service
  tag: 1.2.3-b124khj # The specified tag will be used
  digest: ~

image:
  registry: ~ # The default registry configured for the container platform will be used
  repository: occonnect/soe-service
  tag: 1.2.3-b124khj
  digest: ~

OR

image:
  registry: docker-hosted.central.aws.aok-systems.de
  repository: occonnect/soe-service
  tag: 1.2.3-b124khj
  digest: sha256:1ff6c18fbef2045af6b9c16bf034cc421a29027b800e4f9b68ae9b1cb3e9ae07 # The digest will be used

Example usage:
---
image: {{ include "chc-lib.compute.image" (dict "values" .Values.deployment.image "context" $) }}
...
*/}}

{{- define "chc-lib.compute.image" -}}
{{- $ctx := .context -}}
{{- $separator := ":" -}}
{{- $pin := .values.tag | toString -}}
{{- $registry := .values.registry -}}
{{- $defaultRegistry := $ctx.Values.imageRegistry -}}

{{- if or (kindIs "invalid" $registry) (empty $registry) -}}
  {{- $registry = $defaultRegistry -}}
{{- end }}

{{- if not .values.tag }}
  {{- $pin = $ctx.Chart.AppVersion | toString -}}
{{- end -}}

{{- if .values.digest }}
  {{- $separator = "@" -}}
  {{- $pin = .values.digest | toString -}}
{{- end -}}

{{- if $registry }}
  {{- printf "%s/%s%s%s" $registry .values.repository $separator $pin -}}
{{- else -}}
  {{- printf "%s%s%s"  .values.repository $separator $pin -}}
{{- end -}}
{{- end -}}
