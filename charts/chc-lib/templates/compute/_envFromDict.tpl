{{/*
Returns a list of dicts formatted to use in the env spec for a container in the PodSpec of a PodTemplate.
All key/values are templated.

This helper is meant to be used in "_containerSpec.tpl".

Input scheme:
  dict:
    values: dict
    context: object (global chart context, has to be $)

Example values:
---
env:
  LOG_LEVEL: debug
  SERVICE_NAME: "{{ .Release.Name }}"
  SPECIAL_LEVEL_KEY:
    valueFrom:
      configMapKeyRef:
        name: "{{ .Release.Name }}-config"
        key: special.how

Example usage:
---
env: {{ include "chc-lib.compute.envFromDict" (dict "values" .Values.deployment.env "context" $ctx) | nindent 2 }}
...

Example output:
---
apiVersion: v1
kind: Pod
metadata:
  name: example
  namespace: default
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      containers:
        - name: app
          env:
            - name: LOG_LEVEL
              value: debug

            - name: SERVICE_NAME
              value: release-name

            - name: SPECIAL_LEVEL_KEY
              valueFrom:
                configMapKeyRef:
                  name: release-name-config
                  key: special.how
*/}}

{{- define "chc-lib.compute.envFromDict" -}}
{{- $result := list }}

{{- range $k, $v := .values }}
  {{- $entry := dict "name" $k -}}
  {{- if kindIs "map" $v }}
    {{- $entry = merge $entry $v -}}
  {{- else }}
    {{- $entry = merge $entry (dict "value" $v) -}}
  {{- end }}
  {{- $result = append $result $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($result | toYaml) "context" .context) }}
{{- end }}
