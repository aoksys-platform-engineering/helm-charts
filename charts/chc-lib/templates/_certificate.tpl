{{/*
Template to generate a "Certificate" manifest from.

See "https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.Certificate" for the full API spec.

input scheme:
  dict:
    name: string|nil (optional)
    values: dict
    context: object (has to be $)
*/}}

{{- define "chc-lib.certificate.tpl" }}
{{- $ctx := .context }}
{{- if .values.create }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ .name | default (include "common.names.fullname" $ctx) }}
  namespace: {{ $ctx.Release.Namespace }}
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.annotations)
      "context" $ctx) | nindent 2 }}
spec:
  subject:
    organizations:
      - cert-manager

  {{- if .values.commonName }}
  commonName: {{ tpl (.values.commonName) $ctx }}
  {{- end }}
  {{- if .values.duration }}
  duration: {{ .values.duration }}
  {{- end }}
  {{- if .values.renewBefore }}
  renewBefore: {{ .values.renewBefore }}
  {{- end }}
  {{- if and (empty .values.renewBefore) .values.renewBeforePercentage }}
  renewBeforePercentage: {{ .values.renewBeforePercentage }}
  {{- end }}
  {{- if .values.dnsNames }}
  dnsNames: {{ include "common.tplvalues.render" (dict "value" .values.dnsNames "context" $ctx) | nindent 4 }}
  {{- end }}
  {{- if .values.secret.name }}
  secretName: {{ .values.secret.name }}
  {{- else }}
  secretName: {{ .name | default (include "common.names.fullname" $ctx) }}-tls
  {{- end }}
  secretTemplate:
  {{- include "chc-lib.compute.labels-and-annotations" (dict
      "labels" (list $ctx.Values.commonLabels .values.secret.labels)
      "annotations" (list $ctx.Values.commonAnnotations .values.secret.annotations)
      "context" $ctx) | nindent 4 }}

  {{- $jksEnabled := .values.keystores.jks.create }}
  {{- $pkcs12Enabled := .values.keystores.pkcs12.create }}
  {{- if or $jksEnabled $pkcs12Enabled }}
  keystores:
    {{- if $jksEnabled }}
    jks:
      create: true
      passwordSecretRef:
        name: {{ tpl .values.keystores.jks.secretName $ctx }}
        key: password
    {{- end }}
    {{- if $pkcs12Enabled }}
    pkcs12:
      create: true
      passwordSecretRef:
        name: {{ tpl .values.keystores.pkcs12.secretName $ctx }}
        key: password
    {{- end }}
  {{- end }}

  issuerRef:
    group: {{ .values.issuerRef.group }}
    name: {{ .values.issuerRef.name }}
    kind: {{ .values.issuerRef.kind }}

  {{- if .values.isCA }}
  isCA: true
  {{- end }}

  {{- if .values.usages }}
  usages: {{ .values.usages | toYaml | nindent 4 }}
  {{- end }}

  privateKey: {{ .values.privateKey | toYaml | nindent 4 }}
  {{- if .values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ .values.revisionHistoryLimit }}
  {{- end }}
  {{- if and .values.nameConstraints .values.isCA }}
  nameConstraints: {{ .values.nameConstraints | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
