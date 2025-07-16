{{/*
Returns either a dict containing the configured values for the resources,
or a dict with a preconfigured resources if a preset name is matched.

Input scheme:
  path:
    resources: string|dict

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
      containers:
        - name: example
          resources: {{ include "chc-lib.helpers.resources" (dict "path" .Values.resources) | nindent 12 }}

*/}}

{{- define "chc-lib.helpers.resources" -}}
{{- $presets := dict
  "small" (dict 
      "requests" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "250m" "memory" "384Mi" "ephemeral-storage" "2Gi")
   )

  "medium" (dict 
      "requests" (dict "cpu" "100m" "memory" "256Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "500m" "memory" "768Mi" "ephemeral-storage" "2Gi")
   )

  "large" (dict 
      "requests" (dict "cpu" "200m" "memory" "512Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "1000m" "memory" "1536Mi" "ephemeral-storage" "2Gi")
   )

  "xlarge" (dict 
      "requests" (dict "cpu" "400m" "memory" "1536Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "2000m" "memory" "4192Mi" "ephemeral-storage" "2Gi")
   )

  "xxlarge" (dict 
      "requests" (dict "cpu" "800m" "memory" "4192Mi" "ephemeral-storage" "50Mi")
      "limits" (dict "cpu" "4000m" "memory" "8384Mi" "ephemeral-storage" "2Gi")
   )
}}

{{- if typeIs "string" .path }}
    {{- if hasKey $presets .path -}}
        {{- index $presets .path | toYaml -}}
    {{- else -}}
        {{- printf "ERROR: The resources preset value '%s' is invalid. Allowed values are: %s." .path (join ", " (keys $presets)) | fail -}}
    {{- end -}}
{{- else -}}
    {{- .path | toYaml -}}
{{- end }}
{{- end }}
