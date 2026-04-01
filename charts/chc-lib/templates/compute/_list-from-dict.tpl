{{/*
Helper function that takes a dict as input and returns a list of dicts with templated key/values.
The key of each item will be added as the "keyName" field in each dict of the returned list.
All keys and values go through tpl.

Input scheme:
  dict:
    values: dict
    context: object (has to be $)

Example input values:
---
service:
  ports:
    "{{ .Release.Name }}-https":
      port: 443
      targetPort: 8443
      nodePort: 10443
      protocol: TCP

Example template usage:
---
apiVersion: v1
kind: Service
metadata:
  ...
spec:
  ...
  ports: {{ include "chc-lib.compute.list-from-dict" (dict "values" .Values.service.ports "keyName" "name" "context" $) | nindent 4 }}

Example rendered output:
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
      protocol: TCP
*/}}

{{- define "chc-lib.compute.list-from-dict" -}}
{{- $result := list }}

{{- range $k, $v := .values }}
  {{- $entry := merge (dict $.keyName $k) $v -}}
  {{- $result = append $result $entry -}}
{{- end }}

{{- include "common.tplvalues.render" (dict "value" ($result | toYaml) "context" .context ) }}
{{- end }}
