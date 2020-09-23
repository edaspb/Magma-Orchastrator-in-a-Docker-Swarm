# Magma-Orchastrator-in-a-Docker-Swarm
Step-by-Step Installation Notes

Links:
Magma Platform: https://github.com/magma/magma
Docker Swarm: https://docs.docker.com/engine/install/debian/

Originally Orchestrator's enviroment is designed for deployment in AWS platform.
This guide describes the step how to deploy Orchestrator on your local cloud.

Prerequisites
1. Built and published Orchestrator Containers. See https://magma.github.io/magma/docs/orc8r/deploy_build
2. At least one VM with Debian 10.5 or Ubuntu Server 20.04. Two or more VM is recommended.

1. MariaDB installation and configuration

All steps are executed on orch1 server only.
1.1 `apt install mariadb-server -y`
1.2 `mysql -u root -p`

1.3.`create database magma;`
1.4 `CREATE USER 'magma'@'%' IDENTIFIED BY 'magmaPass';` ### Change 'magmaPass'
1.5 `GRANT ALL PRIVILEGES ON magma.* TO 'magma'@'%';`

1.6 `create database nms;`
1.7 `CREATE USER 'nms'@'%' IDENTIFIED BY 'nmsPass';` ### Change 'nmsPass'
1.8 `GRANT ALL PRIVILEGES ON nms.* TO nms@'%';`
1.9 `FLUSH PRIVILEGES;`
1.10 `exit`

1.11 Open file `/etc/mysql/mariadb.cnf`. Put to the end `sql_mode="ANSI_QUOTES"`

2. Docker Swarm Installation

All steps are executed on both servers, orch1 and orch2

2.1 `apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y`
2.2 `curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
2.3 apt update`
2.4 `apt install docker-ce docker-ce-cli containerd.io -y`
2.5 `systemctl start docker && systemctl enable docker`

3. Docker Swarm Activation

On orch1 VM, it will be Master Swarm node (Please don't forget to change IP address):
3.1 `docker swarm init --advertise-addr 172.18.10.2`
3.2 Copy output string from previous command (something like "docker swarm join --token XXXXX")
Then, on orch2 VM:
3.3 Apply the command which you copy on step 3.2
On orch1, label nodes:
3.4 `docker node update --label-add controller=true orch1`
3.5 `docker node update --label-add metrics=true orch2`

4. Metrics node preconfiguration

On orch2:

4.1 `mkdir -p /magma`
4.2 `mkdir -p /magma/userGrafanaData`
4.3 `mkdir -p /magma/prometheus`
4.4 `mkdir -p /magma/prometheus-configurer/config`
4.5 `mkdir -p /magma/alertmanager-configurer/configs`
4.6 `wget https://raw.githubusercontent.com/magma/magma/v1.2/orc8r/cloud/docker/metrics-configs/prometheus.yml -P /magma/prometheus-configurer/configs/`
4.7 `wget https://raw.githubusercontent.com/magma/magma/v1.2/orc8r/cloud/docker/metrics-configs/alertmanager.yml -P /magma/alertmanager-configurer/configs/`
4.8 `wget https://raw.githubusercontent.com/magma/magma/v1.2/orc8r/cloud/docker/fluentd/conf/fluent.conf -P /magma/fluentd/conf/`
4.9 `chmod -R 777 /magma`

5. Controller node preconfiguration

On Orch1:

5.1 `mkdir -p /magma`
5.2 `mkdir -p /magma/certs`
5.3 `mkdir -p /magma/fluentd`
5.4 `mkdir -p /magma/fluentd/conf`
5.5 `mkdir -p /magma/docker_ssl_proxy`
5.6 `wget https://raw.githubusercontent.com/magma/magma/v1.2/orc8r/cloud/docker/fluentd/conf/fluent.conf -P /magma/fluentd/conf/`
5.7 `wget https://raw.githubusercontent.com/magma/magma/v1.2/nms/app/packages/magmalte/docker/docker_ssl_proxy/proxy_ssl.conf -P /magma/docker_ssl_proxy`
5.8 `wget https://raw.githubusercontent.com/magma/magma/v1.2/nms/app/packages/magmalte/docker/docker_ssl_proxy/cert.pem -P /magma/docker_ssl_proxy`
5.9 `wget https://raw.githubusercontent.com/magma/magma/v1.2/nms/app/packages/magmalte/docker/docker_ssl_proxy/key.pem -P /magma/docker_ssl_proxy`

