FROM python:3.8-slim

ARG SPARK_VERSION=3.1.2

ENV SPARK_VERSION ${SPARK_VERSION}
ENV HADOOP_VERSION 3.2
ENV TAR_FILE spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
ENV SPARK_HOME /opt/spark
ENV PATH "${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin"
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/conf

RUN apt update; \
    apt install -y openjdk-11-jdk \
    wget \
    procps \
    nano \
    curl

# download spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${TAR_FILE}

RUN tar -xzvf ${TAR_FILE} -C /opt; \
    ln -sL /opt/${TAR_FILE%.tgz} ${SPARK_HOME}; \
    rm /${TAR_FILE}

WORKDIR ${SPARK_HOME}


ENV AWS_JARS_VERSION 1.11.874

WORKDIR ${SPARK_HOME}/jars

# install jars
RUN wget "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/$AWS_JARS_VERSION/aws-java-sdk-bundle-$AWS_JARS_VERSION.jar"; \
    wget "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/$AWS_JARS_VERSION/aws-java-sdk-core-$AWS_JARS_VERSION.jar"; \
    wget "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/$AWS_JARS_VERSION/aws-java-sdk-$AWS_JARS_VERSION.jar"; \
    wget "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar"; \
    wget "https://repo1.maven.org/maven2/io/delta/delta-core_2.12/1.0.0/delta-core_2.12-1.0.0.jar";
    # wget "https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark3-bundle_2.12/0.9.0/hudi-spark3-bundle_2.12-0.9.0.jar"; \
    # wget "https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.12/3.1.2/spark-avro_2.12-3.1.2.jar"; \
    # wget "https://repo1.maven.org/maven2/org/apache/hudi/hudi-utilities-bundle_2.12/0.9.0/hudi-utilities-bundle_2.12-0.9.0.jar"

COPY jars/* ${SPARK_HOME}/jars/

RUN ln -s /spark ${SPARK_HOME}

RUN pip3 install delta-spark==1.0.0

WORKDIR ${SPARK_HOME}
