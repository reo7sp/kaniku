_ = require 'lodash'

module.exports = class KanikuModel
  constructor: (args) ->
    _.assignIn(@, @getDefaults(), args)
    @_listeners = {}

  @defaults: (defaults) ->
    @prototype.getDefaults = -> defaults

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

        @prototype[varName] = value
        @prototype[getterName] = -> @[varName]
        @prototype[setterName] = (newValue) ->
          @emit("change:#{camelCaseKey}", newValue, was: @[varName], key: key)
          @[varName] = newValue
        @prototype[updaterName] = (func, args...) ->
          func = @prototype[func] if _.isString(func)
          @prototype[setterName](func(@prototype[getterName], args...))

  @useUpdates: (value = true) ->
    @prototype.needsUpdating = -> value

  needsUpdating: -> false

  on: (keys..., listener) ->
    for key in keys
      @_listeners["change:#{key}"] ?= []
      @_listeners["change:#{key}"].push(listener)
    return

  removeListener: (keys..., listener) ->
    for key in keys
      _.pull(@_listeners["change:#{key}"], listener)
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
