## Trivy Scan Report
{{- if . }}
{{- range . }}
## {{ .Target }}
### Vulnerabilities
{{- if (eq (len .Vulnerabilities) 0) }}
No vulnerabilities found.
{{- else }}
| Package | Vulnerability ID | Severity | Installed Version | Fixed Version | Links |
| ------- | ---------------- | :------: | ----------------- | ------------- | ----- |
{{- range .Vulnerabilities }}
| {{ .PkgName }} | {{ .VulnerabilityID }} | {{ .Vulnerability.Severity }} | {{ .InstalledVersion }} | {{ .FixedVersion }} | {{ .PrimaryURL }} |
{{- end }}

{{- end }} <!-- Vulnerabilities -->

### Misconfigurations
{{- if (eq (len .Misconfigurations ) 0) }}
No misconfigurations found.
{{- else }}
| Type | Misconfiguration ID | Check | Severity | Message |
| ---- | ------------------- | ----- | -------- | ------- |
{{- range .Misconfigurations }}
| {{ .Type }} | {{ .ID }} | {{ .Title }} | {{ .Severity }} | {{ .Message }}<br>{{ .PrimaryURL }} |
{{- end }}

{{- end }} <!-- Misconfigurations -->

{{- end }} <!-- Targets -->

{{- else }}
Trivy Returned Empty Report
{{- end }}
