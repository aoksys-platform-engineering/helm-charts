{{- define "chc-lib.externalsecrets" }}
{{- $externalsecrets := .Values.externalSecretsOperator.externalSecrets }}
{{- if and .Values.externalSecretsOperator.enabled $externalsecrets.create }}
{{- range $k, $v := $externalsecrets.items }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ tpl $k $ }}
  namespace: {{ $.Release.Namespace }}
  {{- include "chc-lib.render.labelsAnnotations" (dict
      "labels" (list $.Values.commonLabels $externalsecrets.labels $v.labels)
      "annotations" (list $.Values.commonAnnotations $externalsecrets.annotations $v.annotations)
      "context" $) | nindent 2 }}
spec:
  refreshPolicy: {{ $v.refreshPolicy | default $externalsecrets.refreshPolicy }}
  refreshInterval: {{ $v.refreshInterval | default $externalsecrets.refreshInterval }}
  secretStoreRef:
    name: {{ $v.secretStoreName | default $externalsecrets.secretStoreName }}
    kind: {{ $v.secretStoreKind | default $externalsecrets.secretStoreKind }}
  
  target:
    name: {{ tpl $k $ }}-es
    creationPolicy: {{ $v.creationPolicy | default $externalsecrets.creationPolicy }}
    deletionPolicy: {{ $v.deletionPolicy | default $externalsecrets.deletionPolicy }}
    template:
      type: {{ $v.secretType | default $externalsecrets.secretType }}
      metadata:
        {{- include "chc-lib.render.labelsAnnotations" (dict
          "labels" (list $.Values.commonLabels $externalsecrets.secretLabels $v.secretLabels)
          "annotations" (list $.Values.commonAnnotations $externalsecrets.secretAnnotations $v.secretAnnotations)
          "context" $) | nindent 8 }}

  {{- if $v.remoteRefs }}
  data:
    {{- range $v.remoteRefs }}
    - secretKey: {{ .secretKey }}
      remoteRef:
        key: {{ ternary (printf "%s/%s" $externalsecrets.basePath .providerSecretName | replace "//" "/") .providerSecretName (ne $externalsecrets.basePath "") }}
        {{- if .providerSecretKey }}
        property: {{ .providerSecretKey }}
        {{- end }}
        decodingStrategy: {{ .decodingStrategy | default $externalsecrets.decodingStrategy }}
        conversionStrategy: {{ .conversionStrategy | default $externalsecrets.conversionStrategy }}
        metadataPolicy: {{ .metadataPolicy | default $externalsecrets.metadataPolicy }}
    {{- end }}
  {{- else }}
  data: {{ list | toYaml }}
  {{- end }}

{{- end }}
{{- end }}
{{- end }}
