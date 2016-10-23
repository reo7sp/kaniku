_ = require 'lodash'
extend = require 'extend'

module.exports = class KanikuModel
  constructor: (args) ->
    _.assignIn(@, @_getKanikuData().defaults) if @_getKanikuData().defaults?
    @_listeners = {}

    for key, value of args
      pascalCaseKey = _.upperFirst(_.camelCase(key))
      setterName = "set#{pascalCaseKey}"
      @[setterName](value)

  @_getKanikuData: ->
    @::_kanikuData ?= {klass: @, data: {}}
    unless @::_kanikuData.klass is @
      @::_kanikuData =
        klass: @
        data: extend(true, {}, @::_kanikuData.data) # _.cloneDeep don't work here properly
    @::_kanikuData.data

  _getKanikuData: ->
    (@_kanikuData ? {}).data ? {}

  @defaults: (defaults) ->
    prettyDefaults = _.cloneDeep(@::getDefaults())
    @_getKanikuData().defaults ?= {}
    @::getDefaults = -> prettyDefaults

    for key, value of defaults
      do (key, value) =>
        camelCaseKey = _.camelCase(key)
        varName = "_k_#{camelCaseKey}"

        @_getKanikuData().defaults[varName] = value
        prettyDefaults[camelCaseKey] = value

        @_makeAccessorsForProp(key, getter: true, setter: true)

  @_makeAccessorsForProp: (key, {getter = false, setter = false, updater = null, getterProperty = null, setterProperty = null} = {}) ->
    camelCaseKey = _.camelCase(key)
    pascalCaseKey = _.upperFirst(camelCaseKey)
    varName = "_k_#{camelCaseKey}"

    @_getKanikuData().propsWithoutGetterPrefix ?= []
    hasNoPrefix = @_getKanikuData().propsWithoutGetterPrefix.includes(camelCaseKey)
    unless hasNoPrefix
      boolMethodPrefixes = ['is', 'are', 'do', 'does', 'have', 'has', 'need', 'needs', 'can', 'could', 'able', 'want', 'wants']
      isBool = _(boolMethodPrefixes).some((it) -> camelCaseKey.startsWith(it))
      hasNoPrefix = isBool

    getterName = if hasNoPrefix then camelCaseKey else "get#{pascalCaseKey}"
    setterName = "set#{pascalCaseKey}"
    updaterName = "update#{pascalCaseKey}"

    if getter
      @::[getterName] = -> @[varName]
    if setter
      @::[setterName] = (newValue) ->
        @emit("change:#{camelCaseKey}")
        if @_getKanikuData().computedPropsDepends?
          for dependant in @_getKanikuData().computedPropsDepends[camelCaseKey]
            @emit("change:#{dependant}")
        @[varName] = newValue
    if getter and setter and (if updater? then updater else true)
      @::[updaterName] = (func, args...) ->
        func = @[func] if _.isString(func)
        @[setterName](func(@[getterName](), args...))

    propertySettings =
      enumerable: true
      configurable: true
      get: -> @[getterName]()
      set: -> @[setterName](arguments...)
    delete propertySettings.get unless (if getterProperty? then getterProperty else getter)
    delete propertySettings.set unless (if setterProperty? then setterProperty else setter)
    Object.defineProperty(@::, "#{if hasNoPrefix then '_' else ''}#{camelCaseKey}", propertySettings)

    @_getKanikuData().madePropAccessors ?= []
    madeAccessors = @_getKanikuData().madePropAccessors[camelCaseKey] = {}
    madeAccessors.getter = getterName if getter
    madeAccessors.setter = setterName if setter

  @_remakeAccessorsForProp: (key) ->
    camelCaseKey = _.camelCase(key)
    @_makeAccessorsForProp(key, @_getKanikuData().madePropAccessors[camelCaseKey]) if @_getKanikuData().madePropAccessors?[camelCaseKey]?

  @noAccessorPrefix: (key) ->
    @_getKanikuData().propsWithoutGetterPrefix ?= []
    @_getKanikuData().propsWithoutGetterPrefix.push(_.camelCase(key))

  @computed: (key, {depends} = {}) ->
    camelCaseKey = _.camelCase(key)

    for dependence in depends
      camelCaseDependence = _.camelCase(dependence)
      @_getKanikuData().computedPropsDepends ?= {}
      @_getKanikuData().computedPropsDepends[camelCaseDependence] ?= []
      @_getKanikuData().computedPropsDepends[camelCaseDependence].push(camelCaseKey)
      @_remakeAccessorsForProp(dependence)

    @_makeAccessorsForProp(key, getterProperty: true)

  @useUpdates: (value = true) ->
    @::needsUpdating = -> value

  @getDefaults: -> @::getDefaults()

  @needsUpdating: -> @::needsUpdating()

  on: (keys..., listener) ->
    for key in keys
      @_listeners[key] ?= []
      @_listeners[key].push(listener)
    return

  removeListener: (keys..., listener) ->
    for key in keys
      _.pull(@_listeners[key], listener)
    return

  emit: (listenKey, args...) ->
    if listenKey.includes(':')
      @emit(listenKey.split(':').slice(0, -1).join(':'), args...)
    if @_listeners[listenKey]?
      for listener in @_listeners[listenKey]
        listener(args...)
    return

  needsUpdating: -> false

  update: (dt) -> # abstract

  getDefaults: -> {}

  getData: ->
    data = {}
    for key, accessors of @_getKanikuData().madePropAccessors ? []
      data[key] = @[accessors.getter]()
    data
