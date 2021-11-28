from pyspark.sql.session import SparkSession

spark = SparkSession \
    .builder \
    .config('spark.serializer', 'org.apache.spark.serializer.KryoSerializer') \
    .getOrCreate()

df = spark.read.parquet('/sample')

tableName = 'sample'
primaryKey = 'id'
partitionField = 'date'
precombinedField = 'ts'

hudi_options = {
    'hoodie.table.name': tableName,
    'hoodie.datasource.write.recordkey.field': primaryKey,
    'hoodie.datasource.write.partitionpath.field': partitionField,
    'hoodie.datasource.write.table.name': tableName,
    'hoodie.datasource.write.operation': 'upsert',
    'hoodie.datasource.write.precombine.field': precombinedField,
    'hoodie.upsert.shuffle.parallelism': 1,
    'hoodie.insert.shuffle.parallelism': 1,
    'hoodie.datasource.write.table.type': 'MERGE_ON_READ'
}

df.write.format('hudi').options(**hudi_options).save('/tmp/data/sample')

spark.sql("""
    create table if not exists sample using hudi
    options (type ="mor")
    location "/tmp/data/sample"
""")

spark.sql('UPDATE sample SET name = "test" WHERE id = 1')

spark.close()
