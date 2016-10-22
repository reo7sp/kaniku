module.exports = class KanikuController extends cc.Scene
  constructor: ->
    super

    @models = []
    @updaters = []

  onEnter: ->
    super

    @createModels()
    @createViews()
    @createUpdaters()

    @scheduleUpdate() if @updaters.length > 0 or @models.some((it) -> it.needsUpdating())

  update: (dt) ->
    super

    for updater in @updaters
      if updater.update?
        updater.update(dt)
      else
        updater(dt)

    for model in @models
      model.update(dt) if @model.needsUpdating()

    return

  addModel: (model) ->
    @models.push(model)

  addUpdater: (updater) ->
    @updaters.push(updater)

  createModels: -> # abstract

  createViews: -> # abstract

  createUpdaters: -> # abstract
