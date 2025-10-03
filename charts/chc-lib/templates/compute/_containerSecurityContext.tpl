{{/*
Returns a dict with a securityContext to be used for a container in a PodSpec of a PodTemplate.
If a string value is provided that matches a preset, the preset is returned (e.g. "default").
If values are provided as non empty dict, the values are returned as-is without checking for a preset.

This helper is meant to be used in "_containerSpec.tpl".

Input scheme:
  dict:
    values:
      containerSecurityContext: string|dict|nil (if nil: "default" preset)

Example values:
---
# Freely defined, but empty
containerSecurityContext: {}

OR

# Freely defined
containerSecurityContext:
  privileged: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    add:
      - NET_ADMIN
      - SYS_TIME
    drop:
      - ALL

OR

# Uses the "default" preset
containerSecurityContext: default

Example usage:
---
securityContext: {{ include "chc-lib.compute.containerSecurityContext" (dict "values" .Values.deployment.containers.test.securityContext) | nindent 2 }}
...
*/}}

{{- define "chc-lib.compute.containerSecurityContext" -}}
{{- $presets := dict
  "default" (dict
      "privileged" false
      "allowPrivilegeEscalation" false
      "capabilities" (dict "drop" (list "ALL"))
   )
}}

{{- if kindIs "string" .values }}
  {{- if hasKey $presets .values -}}
    {{- index $presets .values | toYaml -}}
  {{- else -}}
    {{- printf "ERROR: The value '%s' is invalid for a container securityContext. Allowed preset values are: %s." .values (join ", " (keys $presets)) | fail -}}
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
