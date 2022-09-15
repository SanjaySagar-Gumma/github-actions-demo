#Specify a base image
FROM node:alpine

#Working Directory for all the operations
WORKDIR /usr/app

#Install some dependencies
COPY ./package.json ./
RUN npm install
COPY ./ ./

#Default Command
CMD ["npm","start"]