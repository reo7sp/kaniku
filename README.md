# kaniku
MVC microframework for cocos2d-x javascript games.

Kaniku (Japanese: かにく) means flesh of a coconut.

We recommend to use [cocos-starter-kit](https://github.com/reo7sp/cocos-starter-kit) for your games with kaniku.

## Model
Model is the main source of information about game objects. All data flow must come through models.

Models are able to emit events. Views, other models, etc. are allowed to emit events on behalf of the model too.

Method to emit event:
```coffeescript
emit: (listenKey, eventDataForListeners...)
```
```coffeescript
player.emit('died', killer: 'red pacman ghost', killerLevel: 10)
```

Method to subscribe to events:
```coffeescript
on: (listenKeys..., func)
```
```coffeescript
player.on('win', (score) -> postScoreToTheSocialNetwork(score))
```

Example of model:
```coffeescript
class PlayerModel extends kaniku.Model
  @defaults(
    x: 0 # the view will update this variable
    y: 0
    timeAlive: 0
    timeAliveScoreFactor: 100
  )

  @useUpdates()

  update: (dt) ->
    @timeAlive += dt

  @computed 'score', depends: ['x', 'timeAlive', 'timeAliveScoreFactor']
  getScore: ->
    @x + @timeAlive * @timeAliveScoreFactor
```
```coffeescript
player = new PlayerModel(timeAliveScoreFactor: 25) # you can override initial values

player.on 'change:score', ->
  sayPlayerThatHeIsGood()
  
player.setX(10)
```

`defaults` static method sets initial values of a model and also generates getters and setters for all listed variables. So it's important to list variables even with null initial values to let getters and setters to be automatically generated.

Getters and setters are available both method-style (`m.getX()`, `m.setX(1)`) and property-style (`m.x`, `m.x = 1`). We recommend using property-style internally in a model and method-style when accessing model.

Generated setters emit event `change:VARIABLE_NAME`.

You can define computed variables via `computed` static method. This method makes change event of this computed variable to be emited on depending variables change. Also it creates property alias for getter.

`useUpdates` method requests controller to call model's `update` method on every frame. The first argument of model's `update` method is time between frames in seconds.

To get defaults of model use method `getDefaults` which is available both for class and for instances. To get all variables of model (including computed) use method `getData`.


## View
View provides interface between model and real world. Views are usually cocos2d-x Node objects, which render game objects on the user's screen.

There are no Kaniku class to extend from.

Views don't communicate with each other. They communicate through models.

## Controller
Controller is something like glue between all components of the game. It creates models and views and links them with each other.

Controllers are derived from cocos2d-x Scene class.

Updaters do some global work which may affect multiple views and models. Updaters are called each frame.

Updater can be any object which has `update` method (for example, `kaniku.Updater`) or it can be just a function.

Example:
```coffeescript
class FirstLevelController extends kaniku.Controller
  createModels: ->
    @playerModel = new PlayerModel(x: 0, y: 100)
    @addModel(@playerModel)

    @npcModel = new FirstLevelNPCModel()
    @npcModel.setPlayer(@playerModel)
    @addModel(@npcModel)

  createViews: ->
    uiLayer = new cc.Layer()

    scoreView = new ScoreLabelView() # suppose it extends from cc.Label
    scoreView.setPlayer(@playerModel)
    uiLayer.addChild(scoreView)

    @addChild(uiLayer, 2) # cc.Scene method

    gameWorldLayer = new GameWorldLayer()

    playerView = new PlayerView()
    # Suppose this object call physics engine internally and then
    # update player model with new coodinates.
    #
    # Score view will receive event that something was changed in the model,
    # model will compute new score and then
    # score view will finally update the label on screen using model data.
    playerView.setPlayer(@playerModel)
    gameWorldLayer.addChild(playerView)

    @addChild(gameWorldLayer, 1)

  createUpdaters: ->
    @addUpdater (dt) =>
      @player.on 'change:x', (x) ->
        generateGameWorldAfter(x)
```
