## Trivy Scan Report
{{- if . }}
{{- range . }}
## {{ .Target }}
{{- if (eq (len .Vulnerabilities) 0) }}
No vulnerabilities found.
{{- else }}
| Package | Vulnerability ID | Severity | Installed Version | Fixed Version | Links |
| ------- | ---------------- | :------: | ----------------- | ------------- | ----- |
{{- range .Vulnerabilities }}
| {{ .PkgName }} | {{ .VulnerabilityID }} | {{ .Vulnerability.Severity }} | {{ .InstalledVersion }} | {{ .FixedVersion }} | {{ .PrimaryURL }} |
{{- end }}

{{- end }} <!-- Vulnerabilities -->

{{- end }} <!-- Targets -->

{{- else }}
Trivy Returned Empty Report
{{- end }}
