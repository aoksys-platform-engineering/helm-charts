{{/*
Helper function that returns a dict with a securityContext to be used for a pod.

If a string is provided that matches a preset, the preset values are returned.
If nil or empty values are provided, the "default" preset values are returned.
If values are provided as a non empty dict, they are returned as-is.

This helper is meant to be used in "specs/_pod.tpl".

Input scheme:
  dict:
    values:
      securityContext: string|dict|nil (if nil: "default" preset)

Example input values:
---
# Nil value returns "default" preset values
securityContext: ~

OR

# Empty dict returns the "default" preset values
securityContext: {}

OR

# Custom values
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
  seccompProfile:
    type: RuntimeDefault

OR

# Returns values for the "strict" preset if it exists or throws an error, if it doesn't exist
securityContext: strict
*/}}

{{- define "chc-lib.compute.pod-security-context" -}}
{{- $presets := dict
  "openshift" (dict)
  "default" (dict 
      "runAsNonRoot" true
      "seccompProfile" (dict "type" "RuntimeDefault")
   )
}}

{{- if kindIs "string" .values }}
  {{- if hasKey $presets .values }}
    {{- index $presets .values | toYaml -}}
  {{- else }}
    {{- printf "ERROR: The preset '%s' is invalid. Allowed preset values are: %s." .values (join ", " (keys $presets)) | fail }}
  {{- end }}
{{- end }}

{{- if or (empty .values) (kindIs "invalid" .values) }}
  {{- index $presets "default" | toYaml -}}
{{ else if kindIs "map" .values }}
  {{- .values | toYaml -}}
{{- end }}
{{- end }}
