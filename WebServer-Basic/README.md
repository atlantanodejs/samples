Node-WebServer
=========

## Introduction
This is a just a VERY simple WebServer using Node.js

## Notes
The facebook authentication requires facebook_id and facebook_secret.
In Windows, you can set facebook_id=YourFaceBookId and set facebook_secret=YourFaceBookSecret
In Linux/Mac, you can export FACEBOOOK_ID=YourFaceBookId and export FACEBOOKSECRET=YourFaceBookSecret

Thanks for attending!

##Intro to Node.js (as a web server)

Node.js can be used as more than just a web server but I am going to demonstrate some simple functionality of using node.js
with dust, everyauth, and express.

Everyauth is an authentication module I chose to use that allows easy integration with existing authentication like Facebook or LinkedIn

Express is a web api that ties in with node that allows some application configurations with some nice api methods for you to use.

Dust is a templating engine that allows async templating and easy data rendering on pages.

The process of getting started with Node.js is relatively simple:

1. Step 1 -> Install Node.js http://nodejs.org

2. Step 2 -> Create json package npm init

3. Step 3 -> Install packaged npm install ... https://npmjs.org/

4. Step 4 -> Create your server.js

Technically, you are done if you want to simply write out "hello world" to your response directly.
However, most people want to do more than that.

I have created a skeleton app that includes a page, with authentication, and shows you when you are logged in.

path is used for handling file path manipulation
http://nodejs.org/api/path.html

auth is used for the everyauth using facebook in this example
https://github.com/bnoguchi/everyauth

express is a web api used with node to handle js applications in node
http://expressjs.com/

dustjs is a templating engine for node that makes page rendering easier
http://linkedin.github.io/dustjs/
