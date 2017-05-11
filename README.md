# Performance Tuning Under Pressure - Build 2017

This repo contains the demo scripts and sample application for "Performance Tuning Under Pressure" presentation at build 2017.  This presentation walks through an example of making data-driven decisions for optimizing system performance when sudden success has arrived.  The demo breaks down into these sections:

- [cluster-deploy](Cluster deployment).  The demo is based around  multi-container services running on Docker Swarm, with the swarm cluster deployed on Azure via acs-engine. 

- [app-deploy](Application deployment).  The demo application, a contrived ASP.NET Core application with a representative bug baked into the operational path.

- [monitoring-deploy](Monitoring deployment).  The monitoring approach for this demo, in the interest of demonstrating Azure as an open platform, will deploy a Swarm service containing
influxdb and grafana for metrics aggregation and visualization, together with a telegraf agent on each Swarm VM to capature system and container metrics.

- Load generation.  TODO

- Blocking issue identification.  TODO

- Blocking issue resolution.  TODO
  
[cluster-deploy] deploy-cluster/README.md
[app-deploy] sample-apps/0.baseline/README.md
[app-deploy2] sample-apps/1.lightson/README.md
[monitoring-deploy] monitoring/README.md
[load-deploy] load-generation/README.md
 