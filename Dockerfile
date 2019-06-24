#FROM node:12.4.0
FROM node:10.16.0
#FROM node:12.4.0-alpine
LABEL maintainer "Martell <engenharia@elo7.com>"

WORKDIR /home/dev/

COPY ./package*.json ./
RUN npm install

COPY ./ .
RUN npm ci

EXPOSE 3000

CMD [ "npm", "run", "dev" ]
