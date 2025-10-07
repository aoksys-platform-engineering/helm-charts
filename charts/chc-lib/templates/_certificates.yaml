{{- define "chc-lib.certificates" }}
{{- $certificates := .Values.certManager.certificates }}
{{- if and .Values.certManager.enabled $certificates.create }}
{{- range $k, $v := $certificates.items }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $certificates.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $certificates.annotations $v.annotations)
      "context" $) | nindent 2 }}
spec:
  secretName: {{ tpl $k $ }}-tls
  secretTemplate:
    {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $certificates.secretLabels $v.secretLabels)
      "annotations" (list $.Values.commonAnnotations $certificates.secretAnnotations $v.secretAnnotations)
      "context" $) | nindent 4 }}

  {{- if $v.isCA }}
  isCA: true
  {{- end }}

  {{- with $v.usages }}
  usages: {{ . | toYaml | nindent 4 }}
  {{- end }}

  subject:
    organizations:
      - cert-manager

  duration: {{ $v.duration | default $certificates.duration }}
  renewBefore: {{ $v.renewBefore | default $certificates.renewBefore }}
  commonName: {{ tpl ($v.commonName | default $certificates.commonName) $ }}
  dnsNames: {{ include "common.tplvalues.render" (dict "value" ($v.dnsNames | default $certificates.dnsNames ) "context" $) | nindent 4 }}
  privateKey: {{ $v.privateKey | default $certificates.privateKey | toYaml | nindent 4 }}

  {{- $jksEnabled := (or $certificates.keystores.jks.create (($v.keystores).jks).create) }}
  {{- $pkscs12Enabled := (or $certificates.keystores.pkcs12.create (($v.keystores).pkcs12).create) }}
  {{- if (or $jksEnabled $pkscs12Enabled) }}
  keystores:
    {{- if $jksEnabled }}
    jks:
      create: true
      passwordSecretRef:
        name: {{ tpl (default $certificates.keystores.jks.passwordSecretRef.name ((($v.keystores).jks).passwordSecretRef).name) $ }}
        key: {{ ((($v.keystores).jks).passwordSecretRef).key | default $certificates.keystores.jks.passwordSecretRef.key }}
    {{- end }}
    {{- if $pkscs12Enabled }}
    pkcs12:
      create: true
      passwordSecretRef:
        name: {{ tpl (default $certificates.keystores.pkcs12.passwordSecretRef.name ((($v.keystores).pkcs12).passwordSecretRef).name) $ }}
        key: {{ ((($v.keystores).pkcs12).passwordSecretRef).key | default $certificates.keystores.pkcs12.passwordSecretRef.key }}
    {{- end }}
  {{- end }}

  issuerRef:
    group: cert-manager.io
    name: {{ $v.issuerName | default $certificates.issuerName }}
    kind: {{ $v.issuerKind | default $certificates.issuerKind }}
{{- end }}
{{- end }}
{{- end }}
