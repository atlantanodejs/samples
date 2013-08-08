var path = require('path'), 
	auth = require('./auth'),
    express = require('express'),
    dust = require('dustjs-linkedin'),
    //less = require('less-middleware'),
    consolidate = require('consolidate'),
    app = express(),
    env = process.env;

auth.configure(function () {
    // todo: write some real repositories
    auth.use(auth.facebook({
        appId: env.FACEBOOK_ID,
        appSecret: env.FACEBOOK_SECRET,
        redirectPath: '/',
        repository: require('./repositories').user
    }));
});

app.configure(function () {
    app.set('views', path.join(__dirname, 'views'));
    app.set('view engine', 'dust');
    app.engine('dust', consolidate.dust);
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.cookieParser());
	app.use(express.session({ secret: 'secret' }));
	app.use(auth.middleware());
});

function renderView(req,res){
	res.render('index',{ title: 'Hello World', mynewobj: 'HI!', user: req.user } );
}
app.get('/', renderView);

module.exports = app;
