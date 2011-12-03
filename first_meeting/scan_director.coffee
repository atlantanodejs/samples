#!/usr/bin/env coffee

_ = require 'underscore'
_.templateSettings = { interpolate : /\{\{(.+?)\}\}/g }
path = require "path"
fs = require "fs"

config = 
    TITLE: 'scan_director'
    PORT: 3001
    HOST: '127.0.0.1'
    SCANDIR: "/Users/rick/_dev/",
    SCANMAP: "scans/_scanmap.json"
_.extend config, {BASEURL : _.template "http://{{HOST}}:{{PORT}}/", config }
_.extend config, {SCANS : path.join(config.SCANDIR, config.SCANMAP) }

msg = _.template "{{TITLE}} listening on {{BASEURL}} serving from {{SCANDIR}}", config

#----------------------------

scanmap =  do ->
    map = JSON.parse fs.readFileSync config.SCANS, "utf-8"
    return (key) -> map[key]

urlhash = (key) ->
    try
        urls = scanmap key
        console.log "Key found: #{ key }"
    catch error
        console.log "Key error: #{ key } is not a valid key"
        throw error # catch and return Not Found
    
    base = config.BASEURL
    # path.join normalizes /../ so don't use it with external urls. (really for directory paths anyway) 
    img = base + path.join 'scans', urls[0] 
    prev = base +  path.join 'page', urls[1]
    next = base +  path.join 'page', urls[2]
    {img: img, prev: prev, next: next}
        
template = _.template """
    <html>
        <head><title>&nbsp;</title></head>
        <body style='text-align:center;'>
            <img src={{img}} style='width:100%%;'/><br/>
            <a href={{prev}} accesskey='k'>prev</a>
            <span>  </span>
            <a href={{next}} accesskey='j'>next</a>
        </body>
    </html>
"""
    
routes = 
    '/about': (req, res) ->
        res.text "hello"
    '/page/(\\w+)': (req, res, key) ->
        try
            res.html template urlhash key
        catch error
            res.notFound('Not found')
    '/api/(\\w+)': (req, res, key) ->
        try
            res.json urlhash key
        catch error
            # res.json({})
            res.notFound('Not found')

#----------------------------

connect = require 'connect'
quip = require 'quip'
dispatch = require 'dispatch'

server = connect.createServer()
server.use quip()
server.use dispatch routes
server.use connect.static config.SCANDIR
server.use connect.logger {format: ':method :url :response-time :res[Content-Type]' }
server.listen config.PORT

console.log config
console.log msg
