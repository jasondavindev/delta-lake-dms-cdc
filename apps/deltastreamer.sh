#!/bin/bash
spark-submit \
    --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer \
    $SPARK_HOME/jars/hudi-utilities-bundle_2.12-0.9.0.jar \
    --table-type MERGE_ON_READ \
    --target-table events \
    --target-base-path /tmp/data/delta/events \
    --source-ordering-field updated_at \
    --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --transformer-class org.apache.hudi.utilities.transform.AWSDmsTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --hoodie-conf hoodie.datasource.write.recordkey.field=id \
    --hoodie-conf hoodie.datasource.write.partitionpath.field=role \
    --hoodie-conf hoodie.deltastreamer.source.dfs.root=$S3_BASE_PATH
