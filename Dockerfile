FROM node:12-alpine3.15
WORKDIR /app
COPY . /app
RUN npm install

RUN chmod 755 ./bin/launcher-disbalancer-go-client-linux-amd64
ENTRYPOINT ["./run.sh"] 