_ = require 'lodash'

module.exports = class KanikuModel
  constructor: (args) ->
    _.assignIn(@, @getDefaults(), args)
    @_listeners = {}

  @defaults: (defaults) ->
    @prototype.getDefaults = -> defaults

    for k, v of defaults
      do (k, v) =>
        @prototype[k] = v

        @prototype["get#{_.upperFirst(_.camelCase(k))}"] = -> @[k]

        @prototype["set#{_.upperFirst(_.camelCase(k))}"] = (newValue) ->
          @emit("change:#{k}", newValue, was: @[k], key: k)
          @[k] = newValue

  @useUpdates: (value = true) ->
    @prototype.needsUpdating = value

  needsUpdating: false

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
