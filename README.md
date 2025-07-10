# Purpose
Helm repository hosting library and application charts developed at AOK Systems GmbH.

# Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add aoksys-pe https://aoksys-platform-engineering.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
aoksys-pe` to see the charts.
