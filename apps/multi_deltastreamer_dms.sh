#!/bin/bash
spark-submit \
    --class org.apache.hudi.utilities.deltastreamer.HoodieMultiTableDeltaStreamer \
    $SPARK_HOME/jars/hudi-utilities-bundle_2.12-0.7.0.jar \
    --table-type COPY_ON_WRITE \
    --base-path-prefix /tmp/data/multi/ \
    --props /apps/configs/source.props \
    --config-folder /apps/configs \
    --target-table xpto \
    --source-ordering-field updated_at \
    --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --transformer-class org.apache.hudi.utilities.transform.AWSDmsTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --min-sync-interval-seconds 10 \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --continuous