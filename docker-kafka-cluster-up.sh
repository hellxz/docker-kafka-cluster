#/bin/bash
# start up the kafka cluster.
cd ./kafka-01 && docker-compose up -d && \
cd ../kafka-02 && docker-compose up -d && \
cd ../kafka-03 && docker-compose up -d && \
cd ..
