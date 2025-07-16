{{/*
Returns either a dict containing the configured values for the podSecurityContext,
or a dict with a preconfigured podSecurityContext if a preset name is matched.

Input scheme:
  path:
    podSecurityContext: string|dict

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
      securityContext: {{ include "chc-lib.helpers.podSecurityContext" (dict "path" .Values.podSecurityContext) | nindent 8 }}
      containers:
        - name: example
          ...
*/}}

{{- define "chc-lib.helpers.podSecurityContext" -}}
{{- $presets := dict
  "default" (dict 
      "runAsNonRoot" true
      "seccompProfile" (dict "type" "RuntimeDefault")
   )
}}

{{- if typeIs "string" .path }}
    {{- if hasKey $presets .path -}}
        {{- index $presets .path | toYaml -}}
    {{- else -}}
        {{- printf "ERROR: The podSecurityContext preset value '%s' is invalid. Allowed values are: %s." .path (join ", " (keys $presets)) | fail -}}
    {{- end -}}
{{- else -}}
    {{- .path | toYaml -}}
{{- end }}
{{- end }}
