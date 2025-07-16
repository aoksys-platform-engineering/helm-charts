{{/*
Returns the path to a container image in a container registry.
Can be used as part of a podTemplateSpec.

If no registry is provided, only the repository name is used. In that case,
the default registry configured for the container platform will be used to pull the image,
e.g. "docker.io" or "quay.io" (depending on the platform configuration).

Input scheme:
  ctx: Context to access built-in helm objects. Has to be "$".
  path:
    registry: string|nil
    repository: string
    tag: string|nil (default: .Chart.AppVersion)
    digest: string|nil

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

Example template usage:
---
apiVersion: v1
kind: Pod
metadata:
  name: example
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      containers:
        - name: example
          image: {{ include "chc-lib.helpers.image" (dict "path" .Values.image "ctx" $) }}
          ...
*/}}

{{- define "chc-lib.helpers.image" -}}
{{- $registry := .path.registry -}}
{{- $repository := .path.repository -}}
{{- $separator := ":" -}}
{{- $pin := .path.tag | toString -}}

{{- if not .path.tag }}
    {{- $pin = .ctx.Chart.AppVersion | toString -}}
{{- end -}}

{{- if .path.digest }}
    {{- $separator = "@" -}}
    {{- $pin = .path.digest | toString -}}
{{- end -}}

{{- if $registry }}
    {{- printf "%s/%s%s%s" $registry $repository $separator $pin -}}
{{- else -}}
    {{- printf "%s%s%s"  $repository $separator $pin -}}
{{- end -}}
{{- end -}}
