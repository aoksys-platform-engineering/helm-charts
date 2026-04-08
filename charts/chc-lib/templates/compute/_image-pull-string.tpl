{{/*
Helper function that returns a string to pull a container image with.
This helper is meant to be used in "specs/_container.tpl".

Input scheme:
  dict:
    name: string
    values:
      registry: string|nil
      repository: string
      tag: string|nil (default: .Chart.AppVersion)
      digest: string|nil

    context: object (has to be $)

Example input values:
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
  tag: 1.2.3-b124khj
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
  digest: sha256:1ff6c18fbef2045af6b9c16bf034cc421a29027b800e4f9b68ae9b1cb3e9ae07
*/}}

{{- define "chc-lib.compute.image-pull-string" -}}
{{- $ctx := .context -}}
{{- $separator := ":" -}}
{{- $pin := .values.tag | toString -}}
{{- $registry := .values.registry -}}
{{- $defaultRegistry := $ctx.Values.imageRegistry -}}

{{- if not .values.repository }}
{{- fail (printf "The '%s' container has no value for 'image.repository' configured" .name) }}
{{- end }}

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
  {{- printf "%s%s%s" .values.repository $separator $pin -}}
{{- end -}}
{{- end -}}
