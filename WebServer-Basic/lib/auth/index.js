var everyauth = require('everyauth');

module.exports = {
    middleware: everyauth.middleware,
    helpExpress: everyauth.helpExpress,
    get: function (name) {
        var settings = (this.settings = this.settings || {});
        return settings[name];
    },
    set: function (name, value) {
        var settings = (this.settings = this.settings || {});
        settings[name] = value;
    },
    use: function (middleware) {
        middleware(this, everyauth);
    },
    configure: function (configurator) {
        if (typeof configurator === 'function') {
            configurator();
        }     
    },
    facebook: function (settings) {
        var me = this,
            options = settings || {};

        return function (auth, everyauth) {
            var repository = options['repository'];

            everyauth.everymodule
                .findUserById(function (id, callback) {
                    me.findById(id, repository, callback);
                });

            everyauth.facebook
                .appId(options['appId'])
                .appSecret(options['appSecret'])
                .findOrCreateUser(function (s, at, ate, fbm) {
                    var promise = this.Promise();
                    
                    me.findOrCreateUser(fbm, repository, function (error, user) {
                        if (error) {
                            return promise.fail(error);
                        }
                        promise.fulfill(user);
                    });

                    return promise;
                })
                .redirectPath(options['redirectPath'] || '/');
        };
    },
    findById: function (id, repository, callback) {
        repository.findById(id, function (error, user) {
            if (error) {
                return callback(error);
            }

            callback(null, user);
        });
    },
    findOrCreateUser: function (user, repository, callback) {
        repository.findById(user.id, function (error, persisted) {
            if (error) {
                return callback(error);
            }

            if (!persisted) {
                repository.create(user, function (error, persisted) {
                    if (error) {
                        return callback(error);
                    }

                    callback(null, persisted);
                });
            } else {
                callback(null, persisted);
            }
        });
    }
};