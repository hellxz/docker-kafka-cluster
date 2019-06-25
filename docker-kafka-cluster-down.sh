#/bin/bash
# docker-compose down the kafka-cluster.
cd ./kafka-01 && docker-compose down && \
cd ../kafka-02 && docker-compose down && \
cd ../kafka-03 && docker-compose down && \
cd ..
