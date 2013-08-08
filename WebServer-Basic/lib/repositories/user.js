var repository = require('./memory').createRepository({
    database: 'workflow',
    host: '127.0.0.1',
    port: 27017,
    collection: 'users'
});

var temp = repository.create;

repository.create = function (user, callback) {
    user.role = 'client';
    temp.apply(repository, [user, callback]);
};

module.exports = repository;