FROM giggio/node-base
MAINTAINER Giovanni Bassi <giggio@giggio.net>

#install app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD package.json /usr/src/app/
ADD bower.json /usr/src/app/
ADD .bowerrc /usr/src/app/
ADD Gruntfile.coffee /usr/src/app/
RUN [ "npm", "install" ]
RUN [ "./node_modules/.bin/bower", "install", "--allow-root" ]
ADD . /usr/src/app
RUN [ "./node_modules/.bin/grunt", "install" ]

EXPOSE 3000

ENTRYPOINT [ "./dockerRun" ]
