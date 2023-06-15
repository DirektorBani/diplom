local kp =
  (import 'kube-prometheus/main.libsonnet') +
   (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
   (import 'kube-prometheus/addons/node-ports.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      grafana+:: {
        config+: {
          sections+: {
             # grafana access URL
             server+: {
               root_url: 'https://158.160.51.121/',
             },
             # default dashboard
             dashboards+: {
               default_home_dashboard_path: '/grafana-dashboard-definitions/0/nodes/nodes.json',
             },
             # predefined credentials
             security+: {
               admin_user: 'admin',
               admin_password: 'admin'
             },
           },
        },
      },
    },
    grafana+: {
        networkPolicy:: {},
    },
  };
{
  ['setup/' + resource]: kp[component][resource]
  for component in std.objectFields(kp)
  for resource in std.filter(
    function(resource)
      kp[component][resource].kind == 'CustomResourceDefinition' || kp[component][resource].kind == 'Namespace', std.objectFields(kp[component])
  )
} +
{
  [component + '-' + resource]: kp[component][resource]
  for component in std.objectFields(kp)
  for resource in std.filter(
    function(resource)
      kp[component][resource].kind != 'CustomResourceDefinition' && kp[component][resource].kind != 'Namespace', std.objectFields(kp[component])
  )
}
{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }