{{/*
Returns either a dict containing the configured values for the containerSecurityContext,
or a dict with a preconfigured containerSecurityContext if a preset name is matched.

Input scheme:
  path:
    containerSecurityContext: string|dict

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
          securityContext: {{ include "chc-lib.helpers.containerSecurityContext" (dict "path" .Values.containerSecurityContext) | nindent 12 }}
          ...
*/}}

{{- define "chc-lib.helpers.containerSecurityContext" -}}
{{- $presets := dict
  "default" (dict
      "privileged" false
      "allowPrivilegeEscalation" false
      "capabilities" (dict "drop" (list "ALL"))
   )
}}

{{- if typeIs "string" .path }}
    {{- if hasKey $presets .path -}}
        {{- index $presets .path | toYaml -}}
    {{- else -}}
        {{- printf "ERROR: The containerSecurityContext preset value '%s' is invalid. Allowed values are: %s." .path (join ", " (keys $presets)) | fail -}}
    {{- end -}}
{{- else -}}
    {{- .path | toYaml -}}
{{- end }}
{{- end }}
