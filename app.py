from pyspark.sql.session import SparkSession
from delta.tables import *
import pyspark.sql.functions as F

spark = SparkSession \
    .builder \
    .config('fs.s3a.aws.credentials.provider', 'com.amazonaws.auth.EnvironmentVariableCredentialsProvider') \
    .getOrCreate()

spark.sparkContext.setLogLevel('ERROR')

streamSource = '/tmp/data/files'
tempDf = spark.read.parquet('/tmp/data/files')
schema = tempDf.schema

existingTables = [table.name for table in spark.catalog.listTables()]

if 'events' not in existingTables:
    tempDf.write.mode('overwrite').format('delta').saveAsTable('events')

deltaTable = DeltaTable.forPath(spark, path='/tmp/data/delta/events')


def upsertToDelta(microBatchOutputDF: DataFrame, _):
    microBatchOutputDF = microBatchOutputDF \
        .withColumn('seq_id', F.monotonically_increasing_id())

    latest = microBatchOutputDF \
        .groupBy('id')\
        .agg(
            F.max('updated_at').alias('updated_at'),
            F.max('seq_id').alias('seq_id')
        ) \
        .alias('mx') \
        .join(
            microBatchOutputDF.alias('df'),
            ['id', 'updated_at', 'seq_id'],
            'inner')
    
    latest = latest.drop('seq_id')

    deltaTable.alias("t").merge(
        latest.alias("s"),
        "s.id = t.id") \
        .whenMatchedUpdateAll() \
        .whenNotMatchedInsertAll(condition="s.Op == 'I'") \
        .execute()


df = spark \
    .readStream \
    .option("checkpointLocation", "/tmp/checkpointdir") \
    .schema(schema) \
    .parquet(streamSource)

df.writeStream \
    .format('delta') \
    .outputMode('update') \
    .foreachBatch(upsertToDelta) \
    .option('checkpointLocation', '/tmp/checkpointstreamdir') \
    .start() \
    .awaitTermination()
