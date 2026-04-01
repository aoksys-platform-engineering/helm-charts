{{/*
Generates a list of arbitrary kubernetes manifests to deploy.

Input scheme:
  dict:
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.extra-manifests.tpl" }}
{{- $ctx := .context }}
{{- range .values.extraManifests }}
---
{{ tpl (toYaml .) $ctx }}
{{- end }}
{{- end }}
