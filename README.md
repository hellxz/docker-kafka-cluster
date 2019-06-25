## Docker-compose Kafka Cluster

Zookeeper容器的虚拟化集群，使用Docker-compose构建，通过主机网络进行沟通，配合[我的博客](https://www.cnblogs.com/hellxz/p/docker_zookeeper_cluster_and_kafka_cluster.html)食用更佳

### 目录结构

```bash
├── docker-kafka-cluster-down.sh
├── docker-kafka-cluster-up.sh
├── kafka-01
│   ├── docker-compose.yml
│   └── .env
├── kafka-02
│   ├── docker-compose.yml
│   └── .env
├── kafka-03
│   ├── docker-compose.yml
│   └── .env
└── kafka-manager
    ├── docker-compose.yml
    └── .env
```

### 文件说明

以`kafka-01`目录举例

其下的`.env`只需要填写`ZOO_SERVERS`,即zookeeper单体/集群的`ip:端口`,以`,`分隔

```properties
# default env for kafka docker-compose.yml
# set zookeeper cluster, pattern is "zk1-host:port,zk2-host:port,zk3-host:port", use a comma as multiple servers separator.
ZOO_SERVERS=10.2.114.110:2181,10.2.114.111:2182,10.2.114.112:2183
```

其下的`docker-compose.yml`，为docker-compse的配置文件

```yaml
version: "3"
services:
    kafka-1:
        image: wurstmeister/kafka:2.12-2.1.1
        restart: always
        container_name: kafka-1
        environment:
            - KAFKA_BROKER_ID=1 #kafka的broker.id，区分不同broker
            - KAFKA_LISTENERS=PLAINTEXT://kafka1:9092 #绑定监听9092端口
            - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka1:9092 #绑定发布订阅的端口
            - KAFKA_ZOOKEEPER_CONNECT=${ZOO_SERVERS} #连接zookeeper的服务地址
            - KAFKA_MESSAGE_MAX_BYTES=2000000 #单条消息最大字节数
            #- KAFKA_CREATE_TOPICS=Topic1:1:3,Topic2:1:1:compact #创建broker时创建的topic:partition-num:replica-num[:clean.policy]
        network_mode: "host"
```

> `KAFKA_CREATE_TOPICS`使用官方说明：`Topic 1` will have 1 partition and 3 replicas, `Topic 2` will have 1 partition, 1 replica and a `cleanup.policy` set to `compact`. 文档地址：<https://hub.docker.com/r/wurstmeister/kafka>

## 使用说明

1. 使用前确保各主机可以互相ping通

2. 确保zookeeper的服务列表与各对应的zookeeper的ip与客户端口相同，如不同注意修改`.env`，集群中`.env`文件相同，可scp复制

3. 确保zookeeper集群启动

4. 复制kafka-01到第一台主机、复制kafka-02到第二台主机、复制kafka-03到第三台主机

5. 确保这几台主机对应的占用端口号不被占用 `kafka-01对应9092`、 `kafka-02对应9093`、` kafka-03对应9094`

6. 分别对每一台kafka-0x所在的主机修改`/etc/hosts`，例

   ```bash
   10.2.114.110	kafka1
   10.2.114.111	kafka2
   10.2.114.112	kafka3
   ```

   > 其中每个主机只需要设置自己的主机上的host，比如我复制了`kafka-01`我就写`本机ip	kafka1` ,依次类推.

7. 单台主机部署kafka集群请为`docker-kafka-cluster-up.sh`与`docker-kafka-cluster-down.sh`授执行权，不要移动目录，通过这两个shell脚本来启动项目；多台主机请手动进入`kafka-0x`目录下，执行`docker-compose up -d`以后台启动，执行`docker-compose down`以移除容器

