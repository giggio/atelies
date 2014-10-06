FROM giggio/node-base
MAINTAINER Giovanni Bassi <giggio@giggio.net>

VOLUME /var/atelies
WORKDIR /var/atelies

#install node tools
RUN [ "npm", "install", "-g", "bower", "grunt-cli", "coffee-script", "mocha", "node-inspector", "nodemon", "coffeelint", "js2coffee", "gulp" ]

#expose dev port
EXPOSE 3000
#expose debug port
EXPOSE 5858

ENTRYPOINT [ "/bin/bash" ]
