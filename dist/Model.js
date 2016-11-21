// Generated by CoffeeScript 1.10.0
(function() {
  var KanikuModel, _, extend,
    slice = [].slice;

  _ = require('lodash');

  extend = require('extend');

  module.exports = KanikuModel = (function() {
    function KanikuModel(args) {
      var key, pascalCaseKey, setterName, value;
      if (this._getKanikuData().defaults != null) {
        _.assignIn(this, this._getKanikuData().defaults);
      }
      this._listeners = {};
      for (key in args) {
        value = args[key];
        pascalCaseKey = _.upperFirst(_.camelCase(key));
        setterName = "set" + pascalCaseKey;
        this[setterName](value);
      }
    }

    KanikuModel._getKanikuData = function() {
      var base;
      if ((base = this.prototype)._kanikuData == null) {
        base._kanikuData = {
          klass: this,
          data: {}
        };
      }
      if (this.prototype._kanikuData.klass !== this) {
        this.prototype._kanikuData = {
          klass: this,
          data: extend(true, {}, this.prototype._kanikuData.data)
        };
      }
      return this.prototype._kanikuData.data;
    };

    KanikuModel.prototype._getKanikuData = function() {
      var ref, ref1;
      return (ref = ((ref1 = this._kanikuData) != null ? ref1 : {}).data) != null ? ref : {};
    };

    KanikuModel.defaults = function(defaults) {
      var base, key, prettyDefaults, results, value;
      prettyDefaults = _.cloneDeep(this.prototype.getDefaults());
      if ((base = this._getKanikuData()).defaults == null) {
        base.defaults = {};
      }
      this.prototype.getDefaults = function() {
        return prettyDefaults;
      };
      results = [];
      for (key in defaults) {
        value = defaults[key];
        results.push((function(_this) {
          return function(key, value) {
            var camelCaseKey, varName;
            camelCaseKey = _.camelCase(key);
            varName = "_p_" + camelCaseKey;
            _this._getKanikuData().defaults[varName] = value;
            prettyDefaults[camelCaseKey] = value;
            return _this._makeAccessorsForProp(key, {
              getter: true,
              setter: true
            });
          };
        })(this)(key, value));
      }
      return results;
    };

    KanikuModel._makeAccessorsForProp = function(key, arg) {
      var base, base1, boolMethodPrefixes, camelCaseKey, getter, getterName, getterProperty, hasNoPrefix, isBool, madeAccessors, pascalCaseKey, propertySettings, ref, ref1, ref2, ref3, ref4, ref5, setter, setterName, setterProperty, updater, updaterName, varName;
      ref = arg != null ? arg : {}, getter = (ref1 = ref.getter) != null ? ref1 : false, setter = (ref2 = ref.setter) != null ? ref2 : false, updater = (ref3 = ref.updater) != null ? ref3 : null, getterProperty = (ref4 = ref.getterProperty) != null ? ref4 : null, setterProperty = (ref5 = ref.setterProperty) != null ? ref5 : null;
      camelCaseKey = _.camelCase(key);
      pascalCaseKey = _.upperFirst(camelCaseKey);
      varName = "_p_" + camelCaseKey;
      if ((base = this._getKanikuData()).propsWithoutGetterPrefix == null) {
        base.propsWithoutGetterPrefix = [];
      }
      hasNoPrefix = this._getKanikuData().propsWithoutGetterPrefix.includes(camelCaseKey);
      if (!hasNoPrefix) {
        boolMethodPrefixes = ['is', 'are', 'do', 'does', 'have', 'has', 'need', 'needs', 'can', 'could', 'able', 'want', 'wants'];
        isBool = _(boolMethodPrefixes).some(function(it) {
          return camelCaseKey.startsWith(it);
        });
        hasNoPrefix = isBool;
      }
      getterName = hasNoPrefix ? camelCaseKey : "get" + pascalCaseKey;
      setterName = "set" + pascalCaseKey;
      updaterName = "update" + pascalCaseKey;
      if (getter) {
        this.prototype[getterName] = function() {
          return this[varName];
        };
      }
      if (setter) {
        this.prototype[setterName] = function(newValue) {
          var dependant, i, len, ref6, ref7;
          this.emit("change:" + camelCaseKey);
          if (((ref6 = this._getKanikuData().computedPropsDepends) != null ? ref6[camelCaseKey] : void 0) != null) {
            ref7 = this._getKanikuData().computedPropsDepends[camelCaseKey];
            for (i = 0, len = ref7.length; i < len; i++) {
              dependant = ref7[i];
              this.emit("change:" + dependant);
            }
          }
          return this[varName] = newValue;
        };
      }
      if (getter && setter && (updater != null ? updater : true)) {
        this.prototype[updaterName] = function() {
          var args, func;
          func = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
          if (_.isString(func)) {
            func = this[func];
          }
          return this[setterName](func.apply(null, [this[getterName]()].concat(slice.call(args))));
        };
      }
      propertySettings = {
        enumerable: true,
        configurable: true,
        get: function() {
          return this[getterName]();
        },
        set: function() {
          return this[setterName].apply(this, arguments);
        }
      };
      if (!(getterProperty != null ? getterProperty : getter)) {
        delete propertySettings.get;
      }
      if (!(setterProperty != null ? setterProperty : setter)) {
        delete propertySettings.set;
      }
      Object.defineProperty(this.prototype, "" + (hasNoPrefix ? '_' : '') + camelCaseKey, propertySettings);
      if ((base1 = this._getKanikuData()).madePropAccessors == null) {
        base1.madePropAccessors = [];
      }
      madeAccessors = this._getKanikuData().madePropAccessors[camelCaseKey] = {};
      if (getter || getterProperty) {
        madeAccessors.getter = getterName;
      }
      if (setter || setterProperty) {
        return madeAccessors.setter = setterName;
      }
    };

    KanikuModel._remakeAccessorsForProp = function(key) {
      var camelCaseKey, ref;
      camelCaseKey = _.camelCase(key);
      if (((ref = this._getKanikuData().madePropAccessors) != null ? ref[camelCaseKey] : void 0) != null) {
        return this._makeAccessorsForProp(key, this._getKanikuData().madePropAccessors[camelCaseKey]);
      }
    };

    KanikuModel.noAccessorPrefix = function(key) {
      var base;
      if ((base = this._getKanikuData()).propsWithoutGetterPrefix == null) {
        base.propsWithoutGetterPrefix = [];
      }
      return this._getKanikuData().propsWithoutGetterPrefix.push(_.camelCase(key));
    };

    KanikuModel.computed = function(key, arg) {
      var base, base1, camelCaseDependence, camelCaseKey, dependence, depends, i, len;
      depends = (arg != null ? arg : {}).depends;
      camelCaseKey = _.camelCase(key);
      for (i = 0, len = depends.length; i < len; i++) {
        dependence = depends[i];
        camelCaseDependence = _.camelCase(dependence);
        if ((base = this._getKanikuData()).computedPropsDepends == null) {
          base.computedPropsDepends = {};
        }
        if ((base1 = this._getKanikuData().computedPropsDepends)[camelCaseDependence] == null) {
          base1[camelCaseDependence] = [];
        }
        this._getKanikuData().computedPropsDepends[camelCaseDependence].push(camelCaseKey);
        this._remakeAccessorsForProp(dependence);
      }
      return this._makeAccessorsForProp(key, {
        getterProperty: true
      });
    };

    KanikuModel.useUpdates = function(value) {
      if (value == null) {
        value = true;
      }
      return this.prototype.needsUpdating = function() {
        return value;
      };
    };

    KanikuModel.getDefaults = function() {
      return this.prototype.getDefaults();
    };

    KanikuModel.needsUpdating = function() {
      return this.prototype.needsUpdating();
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
        this.emit.apply(this, [listenKey.split(':').slice(0, -1).join(':')].concat(slice.call(args)));
      }
      if (this._listeners[listenKey] != null) {
        ref = this._listeners[listenKey];
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          listener.apply(null, args);
        }
      }
    };

    KanikuModel.prototype.needsUpdating = function() {
      return false;
    };

    KanikuModel.prototype.update = function(dt) {};

    KanikuModel.prototype.getDefaults = function() {
      return {};
    };

    KanikuModel.prototype.getData = function() {
      var accessors, data, key, ref, ref1;
      data = {};
      ref1 = (ref = this._getKanikuData().madePropAccessors) != null ? ref : [];
      for (key in ref1) {
        accessors = ref1[key];
        data[key] = this[accessors.getter]();
      }
      return data;
    };

    return KanikuModel;

  })();

}).call(this);
