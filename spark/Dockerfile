FROM spark:python3-java17

RUN /opt/spark/bin/spark-sql \
    --conf spark.jars.ivy=/opt/spark/jars \
    --packages io.delta:delta-spark_2.12:3.2.1,io.delta:delta-storage-s3-dynamodb:3.2.1,org.apache.hadoop:hadoop-aws:3.3.4 \
    --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension \
    --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog \
    --e "select 1;"
