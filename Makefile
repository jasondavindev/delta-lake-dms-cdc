run:
	docker run --rm -ti\
		--entrypoint ""\
		--env-file=.env\
		-v ${PWD}/spark-defaults.conf:/opt/spark-3.1.2-bin-hadoop3.2/conf/spark-defaults.conf\
		-v ${PWD}/data:/tmp/data\
		-v ${PWD}/apps/:/apps\
		-w /apps\
		docker-spark bash

build:
	docker build -t docker-spark .
