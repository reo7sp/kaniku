// Generated by CoffeeScript 1.10.0
(function() {
  var KanikuModel, _,
    slice = [].slice;

  _ = require('lodash');

  module.exports = KanikuModel = (function() {
    function KanikuModel(args) {
      var camelCaseKey, key, pascalCaseKey, setterName, value;
      if (this._defaults != null) {
        _.assignIn(this, this._defaults);
      }
      this._listeners = {};
      for (key in args) {
        value = args[key];
        camelCaseKey = _.lowerFirst(_.camelCase(key));
        pascalCaseKey = _.upperFirst(camelCaseKey);
        setterName = "set" + pascalCaseKey;
        this[setterName](value);
      }
    }

    KanikuModel.defaults = function(defaults) {
      var key, prettyDefaults, results, value;
      this.prototype._defaults = {};
      prettyDefaults = {};
      this.prototype.getDefaults = function() {
        return prettyDefaults;
      };
      results = [];
      for (key in defaults) {
        value = defaults[key];
        results.push((function(_this) {
          return function(key, value) {
            var camelCaseKey, getterName, pascalCaseKey, setterName, updaterName, varName;
            camelCaseKey = _.lowerFirst(_.camelCase(key));
            pascalCaseKey = _.upperFirst(camelCaseKey);
            varName = "_k_" + camelCaseKey;
            if (camelCaseKey.startsWith('is')) {
              getterName = camelCaseKey;
            } else {
              getterName = "get" + pascalCaseKey;
            }
            setterName = "set" + pascalCaseKey;
            updaterName = "update" + pascalCaseKey;
            _this.prototype._defaults[varName] = value;
            prettyDefaults[camelCaseKey] = value;
            _this.prototype[getterName] = function() {
              return this[varName];
            };
            _this.prototype[setterName] = function(newValue) {
              this.emit("change:" + camelCaseKey, newValue, {
                was: this[varName],
                key: key
              });
              return this[varName] = newValue;
            };
            return _this.prototype[updaterName] = function() {
              var args, func;
              func = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
              if (_.isString(func)) {
                func = this[func];
              }
              return this[setterName](func.apply(null, [this[getterName]()].concat(slice.call(args))));
            };
          };
        })(this)(key, value));
      }
      return results;
    };

    KanikuModel.useUpdates = function(value) {
      if (value == null) {
        value = true;
      }
      return this.prototype.needsUpdating = function() {
        return value;
      };
    };

    KanikuModel.prototype.needsUpdating = function() {
      return false;
    };

    KanikuModel.prototype.on = function() {
      var base, i, j, key, keys, len, listener;
      keys = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), listener = arguments[i++];
      for (j = 0, len = keys.length; j < len; j++) {
        key = keys[j];
        if ((base = this._listeners)[key] == null) {
          base[key] = [];
        }
        this._listeners[key].push(listener);
      }
    };

    KanikuModel.prototype.removeListener = function() {
      var i, j, key, keys, len, listener;
      keys = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), listener = arguments[i++];
      for (j = 0, len = keys.length; j < len; j++) {
        key = keys[j];
        _.pull(this._listeners[key], listener);
      }
    };

    KanikuModel.prototype.emit = function() {
      var args, i, len, listenKey, listener, ref;
      listenKey = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (listenKey.includes(':')) {
        this.emit(listenKey.split(':').slice(0, -1).join(':'));
      }
      if (this._listeners[listenKey] != null) {
        ref = this._listeners[listenKey];
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          listener.apply(null, args);
        }
      }
    };

    KanikuModel.prototype.getDefaults = function() {
      return {};
    };

    KanikuModel.prototype.getData = function() {
      return _.assign(_.clone(this.getDefaults()), this);
    };

    KanikuModel.prototype.update = function(dt) {};

    return KanikuModel;

  })();

}).call(this);
