{{/*
Takes a dict as input and returns a list of dicts with templated key/values.
The key of each item will be added as the "keyName" field in each dict of the returned list.

Input scheme:
  dict:
    values: dict
    context: object (global chart context, has to be $)

Example values:
---
service:
  ports:
    "{{ .Release.Name }}-https":
      port: 443
      targetPort: 8443
      nodePort: 10443
      porotocol: TCP

Example usage:
---
apiVersion: v1
kind: Service
metadata:
  ...
spec:
  ...
  ports: {{ include "chc-lib.compute.listFromDict" (dict "values" .Values.service.ports "keyName" "name" "context" $) | nindent 4 }}

Example output:
---
apiVersion: v1
kind: Service
metadata:
  ...
spec:
  ...
  ports:
    - name: chc-lib-unittests-https
      port: 443
      targetPort: 8443
      nodePort: 10443
      porotocol: TCP
*/}}

{{- define "chc-lib.compute.listFromDict" -}}
{{- $result := list }}

{{- range $k, $v := .values }}
  {{- $entry := merge (dict $.keyName $k) $v -}}
  {{- $result = append $result $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($result | toYaml) "context" .context ) }}
{{- end }}
