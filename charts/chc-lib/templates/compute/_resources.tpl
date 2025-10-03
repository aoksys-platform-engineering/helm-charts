{{/*
Returns a dict with resources to be used for a container in the PodSpec of a PodTemplate.
If a string value is provided that matches a preset, the preset is returned (e.g. "small").
If values are provided as dict, the values are returned as-is without checking for a preset.

This helper is meant to be used in "_containerSpec.tpl".

Input scheme:
  values:
    resources: string|dict|nil (if nil: "xsmall" preset)

Example values:
---
# Freely defined, but empty
resources: {}

OR

# Freely defined
resources:
  limits:
    cpu: 240m
    memory: 350Mi
  requests:
    cpu: 120m
    memory: 175Mi

OR

# Uses the "small" preset
resources: small

Example usage:
resources: {{ include "chc-lib.compute.resources" (dict "values" .Values.deployment.resources) | nindent 2 }}
...
*/}}

{{- define "chc-lib.compute.resources" -}}
{{- $presets := dict
  "xsmall" (dict 
      "requests" (dict "cpu" "10m" "memory" "64Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "1Gi")
   )

  "small" (dict 
      "requests" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "250m" "memory" "384Mi" "ephemeral-storage" "1Gi")
   )

  "medium" (dict 
      "requests" (dict "cpu" "100m" "memory" "256Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "500m" "memory" "768Mi" "ephemeral-storage" "1Gi")
   )

  "large" (dict 
      "requests" (dict "cpu" "200m" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "1000m" "memory" "1536Mi" "ephemeral-storage" "1Gi")
   )

  "xlarge" (dict 
      "requests" (dict "cpu" "400m" "memory" "1536Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2000m" "memory" "4192Mi" "ephemeral-storage" "1Gi")
   )

  "xxlarge" (dict 
      "requests" (dict "cpu" "800m" "memory" "4192Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4000m" "memory" "8384Mi" "ephemeral-storage" "1Gi")
   )
}}

{{- if kindIs "string" .values }}
  {{- if hasKey $presets .values -}}
    {{- index $presets .values | toYaml -}}
  {{- else -}}
    {{- printf "ERROR: The value '%s' is invalid for container resources. Allowed preset values are: %s." .values (join ", " (keys $presets)) | fail -}}
  {{- end -}}
{{- else -}}
  {{- if kindIs "invalid" .values }}
    {{- index $presets "xsmall" | toYaml -}}
  {{- else if and (empty .values) (kindIs "map" .values) -}}
    {{- dict | toYaml -}}
  {{- else -}}
    {{ .values | toYaml -}}
  {{- end }}
{{- end }}
{{- end }}
