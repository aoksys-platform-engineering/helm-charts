# Example application chart
This chart demonstrates how to use the `chc-lib` library chart to build a custom application chart.
It leverages library templates and default values for reusable resource definitions.

It includes templates for single resources like:

- `Deployment`  
- `Service`  
- `Ingress`  

and also shows how to use the `chc-lib.kafka-topic.tpl` template to create multiple `KafkaTopic` resources at once.

# Render it

Run this command to see the templated kubernetes manifests:

```bash
helm template aoksys-pe/example-app
```

See https://github.com/aoksys-platform-engineering/helm-charts/tree/main/charts/chc-lib for more.
