_ = require 'lodash'

module.exports = class KanikuModel
  constructor: (args) ->
    _.assignIn(@, @_defaults) if @_defaults?
    @_listeners = {}

    for key, value of args
      camelCaseKey = _.lowerFirst(_.camelCase(key))
      pascalCaseKey = _.upperFirst(camelCaseKey)
      setterName = "set#{pascalCaseKey}"
      @[setterName](value)

  @defaults: (defaults) ->
    @prototype._defaults = {}
    prettyDefaults = {}
    @prototype.getDefaults = -> prettyDefaults

    for key, value of defaults
      do (key, value) =>
        camelCaseKey = _.lowerFirst(_.camelCase(key))
        pascalCaseKey = _.upperFirst(camelCaseKey)
        varName = "_k_#{camelCaseKey}"
        if camelCaseKey.startsWith('is')
          getterName = camelCaseKey
        else
          getterName = "get#{pascalCaseKey}"
        setterName = "set#{pascalCaseKey}"
        updaterName = "update#{pascalCaseKey}"

        @prototype._defaults[varName] = value
        prettyDefaults[camelCaseKey] = value
        @prototype[getterName] = -> @[varName]
        @prototype[setterName] = (newValue) ->
          @emit("change:#{camelCaseKey}", newValue, was: @[varName], key: key)
          @[varName] = newValue
        @prototype[updaterName] = (func, args...) ->
          func = @[func] if _.isString(func)
          @[setterName](func(@[getterName](), args...))

  @useUpdates: (value = true) ->
    @prototype.needsUpdating = -> value

  needsUpdating: -> false

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
      @emit(listenKey.split(':').slice(0, -1).join(':'))
    if @_listeners[listenKey]?
      for listener in @_listeners[listenKey]
        listener(args...)
    return

  getDefaults: -> {}

  getData: -> _.assign(_.clone(@getDefaults()), @)

  update: (dt) -> # abstract
