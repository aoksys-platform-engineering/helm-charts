# Changelog

All notable changes to the `chc-lib` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project follows [Semantic Versioning](https://semver.org/).

## [0.51.1] - 2026-04-08

### Added
- Auto-generated docs for the "container" spec which is included in all templates that configure pods
- Option to configure a "workingDir" and "lifecycle" value for containers
- Fail if "image.repository" value is missing for containers and initContainers

### Fixed
- Prevent the usage of the invalid "restartPolicy" value for non initContainers
- Prevent the usage of invalid "lifecycle", "startupProbe", "livenessProbe" and "readinessProbe" values for initContainers

## [0.51.0] - 2026-04-07

### Added
- Templates to support "HTTPRoute", "TLSRoute" and "ReferenceGrant" resources to use the kubernetes gateway API
