#!/bin/bash
spark-submit \
    --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer \
    $SPARK_HOME/jars/hudi-utilities-bundle_2.12-0.7.0.jar \
    --table-type MERGE_ON_READ \
    --target-table users \
    --target-base-path /tmp/data/timestamps/users \
    --source-ordering-field updated_at \
    --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --transformer-class org.apache.hudi.utilities.transform.AWSDmsTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --min-sync-interval-seconds 10 \
    --props /apps/configs/users.props \
    --continuous
