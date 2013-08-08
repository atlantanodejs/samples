var port = 3000;
var serverApp = require('./lib');
require('http').createServer(serverApp).listen(port);
console.log('Server Running...');

