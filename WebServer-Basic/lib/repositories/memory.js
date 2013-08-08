function Repository(data) {
    this.data = data || {};
}

Repository.prototype = {
    list: function (page, pageSize, callback) {
        var data = this.data,
            results = Object.keys(data).splice((page - 1) * pageSize, pageSize).map(function (id) {
                return data[id];
            });

        callback(null, results);
    },
    findById: function (id, callback) {
        return callback(null, this.data[id]);
    },
    create: function (model, callback) {
        console.log(this);
        var data = this.data,
            id = Object.keys(data).length > 0 ? Math.max.apply(Math, Object.keys(data)) + 1 : 1;
        
        return callback(null, (data[(model.id = id)] = model));
    },
    update: function (model, callback) {
        var id = model.id,
            data = this.data;

        return callback(null, (data[id] = model));
    },
    delete: function (model, callback) {
        var id = model.id,
            data = this.data,
            persisted = data[id];

        if (persisted) {
            delete data[id];
        }
        
        callback(null, !!persisted);
    }
};

module.exports = {
    createRepository: function () {
        return new Repository();
    },
    Repository: Repository
};