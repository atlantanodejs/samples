#!/usr/bin/env coffee

DIR = __dirname
PORT = 4000
logFormat = format: ':method :url :response-time :res[Content-Type]' 

connect = require 'connect'

server = connect.createServer()
server.use connect.logger logFormat
server.use connect.static DIR
server.listen PORT
    
console.log DIR, PORT

