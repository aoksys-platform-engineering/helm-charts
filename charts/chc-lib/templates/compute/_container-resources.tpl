{{/*
Helper function that returns a dict with resources to be used for a container.

If a string is provided that matches a preset, the preset values are returned.
If nil or empty values are provided, the "xsmall" preset values are returned.
If values are provided as a non empty dict, they are returned as-is.

This helper is meant to be used in "specs/_container.tpl".

Input scheme:
  values:
    resources: string|dict|nil (if nil/empty: "xsmall" preset)

Example input values:
---
# Nil value returns "xsmall" preset values
resources: ~

OR

# Empty dict returns "xsmall" preset values
resources: {}

OR

# Custom values are returned as-is
resources:
  limits:
    cpu: 240m
    memory: 350Mi
  requests:
    cpu: 120m
    memory: 175Mi

OR

# Returns values for the "medium" preset if it exists or throws an error, if it doesn't exist
resources: medium
*/}}

{{- define "chc-lib.compute.container-resources" -}}
{{- $presets := dict
  "xsmall" (dict 
      "requests" (dict "cpu" "10m" "memory" "64Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "128Mi" "ephemeral-storage" "1Gi")
   )

  "small" (dict 
      "requests" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "384Mi" "ephemeral-storage" "1Gi")
   )

  "medium" (dict 
      "requests" (dict "cpu" "100m" "memory" "256Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "768Mi" "ephemeral-storage" "1Gi")
   )

  "large" (dict 
      "requests" (dict "cpu" "200m" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "1536Mi" "ephemeral-storage" "1Gi")
   )

  "xlarge" (dict 
      "requests" (dict "cpu" "400m" "memory" "1536Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "4192Mi" "ephemeral-storage" "1Gi")
   )

  "xxlarge" (dict 
      "requests" (dict "cpu" "800m" "memory" "4192Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "memory" "8384Mi" "ephemeral-storage" "1Gi")
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
  {{- index $presets "xsmall" | toYaml -}}
{{ else if kindIs "map" .values }}
  {{- .values | toYaml -}}
{{- end }}
{{- end }}
