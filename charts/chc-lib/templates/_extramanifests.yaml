{{- define "chc-lib.extramanifests" }}
{{- range .Values.extraManifests }}
---
{{ tpl (toYaml .) $ }}
{{- end }}
{{- end }}
