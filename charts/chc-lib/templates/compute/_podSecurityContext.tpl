{{/*
Returns a securityContext to be used in the PodSpec of a PodTemplate.
If a string value is provided that matches a preset, the preset is returned (e.g. "default").
If values are provided as dict, the values are returned as-is without checking for a preset.

This helper is meant to be used in "_podSpec.tpl".

Input scheme:
  dict:
    values:
      podSecurityContext: string|dict|nil (if nil: "default" preset)

Example values:
---
# Freely defined, but empty
podSecurityContext: {}

OR

# Freely defined
podSecurityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 1000

OR

# Uses the "default" preset
podSecurityContext: default

Example usage:
securityContext: {{ include "chc-lib.compute.podSecurityContext" (dict "values" .Values.deployment.pod.securityContext) | nindent 2 }}
...
*/}}

{{- define "chc-lib.compute.podSecurityContext" -}}
{{- $presets := dict
  "default" (dict 
      "runAsNonRoot" true
      "seccompProfile" (dict "type" "RuntimeDefault")
   )
}}

{{- if kindIs "string" .values }}
  {{- if hasKey $presets .values -}}
    {{- index $presets .values | toYaml -}}
  {{- else -}}
    {{- printf "ERROR: The value '%s' is invalid for a pod securityContext. Allowed preset values are: %s." .values (join ", " (keys $presets)) | fail -}}
  {{- end -}}
{{- else -}}
  {{- if kindIs "invalid" .values }}
    {{- index $presets "default" | toYaml -}}
  {{- else if and (empty .values) (kindIs "map" .values) -}}
    {{- dict | toYaml -}}
  {{- else -}}
    {{ .values | toYaml -}}
  {{- end }}
{{- end }}
{{- end }}
