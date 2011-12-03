#!/usr/bin/env coffee

"""
    chromeTabs.coffee
    Return the tabs of each window of Chrome in various optional formats
"""

child_process = require "child_process"

osascript = (ascript, options, cb) ->
    command = "osascript -ss "
    for line in ascript.split '\n'
        command += ' -e "' + line.replace(/\"/g, '\\"') + '"'
    child_process.exec command, options, (err, outbuf, errbuf) ->
        if err then cb err else cb null, outbuf
#"
chromeWindows = (cb) ->
    ascript =  """
        tell application "Google Chrome"
            set outlist to {}
            set inlist to windows as list
            repeat with n from 1 to length of inlist
                set windowId to id of item n of inlist as integer
                set end of outlist to windowId
            end repeat
            return outlist
        end tell
    """
    osascript ascript, {}, (err, out) ->
        # outlist = {"path1", "path2", ...} + trailing char
        if err then cb err else cb null, JSON.parse '[' + out.slice(1,-2) + ']' 

windowTabs = (windowId, cb) ->
    ascript = """
        tell application "Google Chrome"
            set outlist to {}
            set inlist to tabs of window id #{windowId} as list
            repeat with n from 1 to length of inlist
                set props to {tabTitle:"", tabURL:""}
                set tabTitle of props to title of item n of inlist
                set tabURL of props to URL of item n of inlist
                set end of outlist to props
            end repeat
            return outlist
        end tell
    """
    osascript ascript, {}, (err, out) ->
        # outlist = {{tabTitle:"title", tabURL:"url"}, {tabTitle:"title", tabURL:"url"}} + trailing char
        if err then cb err else cb null, JSON.parse '[' + out.slice(1,-2).replace(/(\w+)\:\"/g, '"$1":"') + ']' 

#'
#------------------

async = require "async" # see http://caolan.github.com/nimble/
_ = require "underscore"
#dust = require "dust"

# FIX: leaves a stray comma at the end
jsonFormat =
    preWindows: ->
        "["
    preTabs: ->
        "["
    iterator: (tabs) ->
        JSON.stringify tabs
    postTabs: ->
        "],"
    postWindows: ->
        "]"

markdownFormat =
    preWindows: ->
         '\n\n----------------\n\n'
    preTabs: ->
        ""
    iterator: (tabs) ->
        (_.map tabs, (t) -> "[#{t.tabTitle}](#{t.tabURL})").join '\n'
    postTabs: ->
         '\n\n----------------\n\n'
    postWindows: ->
        ""

htmlFormat =
    preWindows: ->
        date = new Date()
        """
            <!DOCTYPE HTML><html><head><title>tabs #{date}</title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
            <hr />\n
        """
    preTabs: ->
        "\n<br/>\n"
    iterator: (tabs) ->
        (_.map tabs, (t) -> "<a href=#{t.tabURL}>#{if t.tabTitle then t.tabTitle else t.tabURL}</a><br/>").join '\n'
    postTabs: ->
        "\n<br/><hr />\n"
    postWindows: ->
        "\n</body></html>"

        
# http://nodejs.org/docs/v0.4.8/api/modules.html#accessing_the_main_module
if require.main == module
    cli = require "cli"
    cli.parse 
        format: ['f', 'html | h | markdown | m | json | j', 'string', 'm']
        stream: ['s', 'Produce the result in chunks', 'bool', false]
    
    # cli.main is only required for daemon, cli.args and cli.options would work here
    cli.main (args, options) ->
        f = options.format.charAt 0
        #console.debug options.format,' ', format,' ', options.stream
        if f == 'j' then format = jsonFormat
        else if f == 'h' then format = htmlFormat
        else if f == 'm' then format = markdownFormat
        else
            console.error "unknown format option"
            process.exit 1
        
        buffer = ""
        sowrite = (text) ->
            #console.debug text
            if !options.stream
                buffer += text # sync
                #console.debug buffer
            else
                process.stdout.write text # node stream
        
        doWindow = (window, cb) ->
            #console.debug window, '\n'
            windowTabs window, (err, tabs) ->
                if err then console.error "chromeWindows windowTabs ", err
                else
                    #console.debug JSON.stringify tabs
                    sowrite format.preTabs() + format.iterator(tabs) + format.postTabs()
                    cb() # forEach needs this
        
        chromeWindows (err, windows) ->
            if err then console.error "chromeWindows ", err
            else
                #console.debug JSON.stringify windows, '\n'
                sowrite format.preWindows()
                # forEachSeries keeps window order, slower
                # forEach does all in parallel, tends to finish windows with fewer tabs first
                async.forEachSeries windows, doWindow, (err) ->
                    if err then console.error "chromeWindows forEach", err
                    else
                        sowrite format.postWindows()
                        if buffer != ""
                            #console.debug "buffer", '\n'
                            process.stdout.write buffer

            
