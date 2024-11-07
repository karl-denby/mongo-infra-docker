# Prometheus and Grafana

## Setup

1. You need to start with an Atlas (Cloud) or Cloud Manager (Cloud) or Ops Manager (On Prem) managed cluster.
1. Navigate to the Alert section and then integrations
1. Configure Prometheus
1. you can make up a username/password, but take note of them, you'll need them in a minute
1. Configure http_sd (instead of file) and Atlas will output a block of text like this.

```yaml
  - job_name: "karl.denby-mongo-metrics"
    scrape_interval: 10s
    metrics_path: /metrics
    scheme : https
    basic_auth:
      username: prom_user_6509817e719c4341040972a2
      password: X2oniGFLkixrrpsF
    http_sd_configs:
      - url: https://cloud.mongodb.com/prometheus/v1.0/groups/666ff4e53f32e174b5f431d3/discovery
        refresh_interval: 60s
        basic_auth:
          username: prom_user_6509817e719c4341040972a2
          password: X2oniGFLkixrrpsF
```

Your's will have a different name (based on Atlas project), your username and password should be whatever you set. Obviously the url will container your project/group id.

Copy this into the `prometheus.yml` file make sure the indentation of 'job_name' lines up.

Change into this folder and run:

```console
docker compose up -d
```

This will start prometheus which will collect and store metrics. It will also start grafana which is a nice way to visualize the data.

## What Next

- You can view Prometheus locally on http://localhost:9090
- You can view Grafana locally on http://localhost:3000
  - username is admin
  - password is admin # needs to be changed on first login
  - You can tell Grafana to use a prometheus data source on http://prometheus.local:9090
  - You can create a dashboard using the prometheus data source with any metric you like
  - If you want an example of a complex query in a graph try something like
  - `sum(rate(hardware_system_cpu_steal_milliseconds{group_id="666ff4e53f32e174b5f431d3"}[30s]) / 10) by (instance)`
  - change the group_id to match your project you may need to switch to code view instead of builder vew 

## Common issues

- prometheus on your laptop has to be able to reach Atlas and be on the IP access list, so if it works for a while, then your IP changes, you may notice it stop working. Go to the Atlas IP access list and add your current IP to get it going again
- If you setup a new cluster you may see old data that has been stored in the /prometheus volume, remove the volume if your just testing and redeploying

## Clean up
- pause everything `docker compose pause`
- un-pause everything `docker compose unpause`
- remove everything `docker compose down`
