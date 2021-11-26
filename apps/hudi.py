from pyspark.sql.session import SparkSession
import pyspark.sql.functions as F

spark = SparkSession \
    .builder \
    .config('spark.serializer', 'org.apache.spark.serializer.KryoSerializer') \
    .getOrCreate()

spark.sparkContext.setLogLevel('ERROR')

tableName = 'events'
primaryKey = 'id'
partitionField = 'insert_date'
precombinedField = 'updated_at'

df = spark.read.parquet('/tmp/data/parquets').filter('Op = "I"').limit(10)
df = df.withColumn(partitionField, F.date_format(df.inserted_at, 'yyyy-MM-dd'))

hudi_options = {
    'hoodie.table.name': tableName,
    'hoodie.datasource.write.recordkey.field': primaryKey,
    'hoodie.datasource.write.partitionpath.field': partitionField,
    'hoodie.datasource.write.table.name': tableName,
    'hoodie.datasource.write.operation': 'upsert',
    'hoodie.datasource.write.precombine.field': precombinedField,
    'hoodie.upsert.shuffle.parallelism': 2,
    'hoodie.insert.shuffle.parallelism': 2
}

df.write.format('hudi').options(
    **hudi_options).mode('append').save('/tmp/data/delta/events')

spark.sql("""
    create table if not exists events using hudi
    options (primaryKey = "id", preCombinedField = "updated_at", type ="mor")
    location "/tmp/data/delta/events"
""")

spark.stop()
