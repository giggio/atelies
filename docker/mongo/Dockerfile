FROM giggio/node-base
MAINTAINER Giovanni Bassi <giggio@giggio.net>

RUN groupadd -r mongodb && useradd -r -g mongodb mongodb
RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' \
	&& chmod +x /usr/local/bin/gosu
VOLUME /data/db
ADD docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 27017
CMD ["mongod"]
