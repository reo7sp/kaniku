global.cc =
  Scene: class
    onEnter: ->
    update: ->
    scheduleUpdate: ->

expect = require('chai').expect
kaniku = require('../src/index.coffee')


describe 'Controller', ->
  class TestController extends kaniku.Controller
    constructor: (
      @createModelsCallback,
      @createViewsCallback,
      @createUpdatersCallback
      @updateModelCallback,
      @dontUpdateModelCallback,
      @functionUpdaterCallback
      @classUpdaterCallback
    ) ->
      super

    createModels: ->
      @createModelsCallback?()

      class T1 extends kaniku.Model
        @useUpdates()
        constructor: (@callback) ->
        update: ->
          @callback?(arguments...)

      class T2 extends T1
        @useUpdates(false)

      @testModel = new T1(@updateModelCallback)
      @addModel @testModel

      @testModelNoUpdates = new T2(@dontUpdateModelCallback)
      @addModel @testModelNoUpdates

    createViews: ->
      @createViewsCallback?()

    createUpdaters: ->
      @createUpdatersCallback?()

      class T extends kaniku.Updater
        constructor: (@callback) ->
        update: -> @callback?(arguments...)

      @addUpdater => @functionUpdaterCallback?(arguments...)
      @addUpdater new T(@classUpdaterCallback)

  describe '#onEnter', ->
    it 'calls #create* methods', ->
      modelsCreated = false
      viewsCreated = false
      updatersCreated = false
      t = new TestController(
        -> modelsCreated = true
        -> viewsCreated = true
        -> updatersCreated = true
      )
      expect(modelsCreated).to.be.false
      expect(viewsCreated).to.be.false
      expect(updatersCreated).to.be.false
      t.onEnter()
      expect(modelsCreated).to.be.true
      expect(viewsCreated).to.be.true
      expect(updatersCreated).to.be.true

  describe '#update', ->
    it 'updates models', ->
      model1Updated = false
      model2Updated = false
      t = new TestController(
        null, null, null
        (dt) -> model1Updated = true; expect(dt).to.equal(1)
        (dt) -> model2Updated = true; expect(dt).to.equal(1)
      )
      expect(model1Updated).to.be.false
      expect(model2Updated).to.be.false
      t.onEnter()
      t.update(1)
      expect(model1Updated).to.be.true
      expect(model2Updated).to.be.false

    it 'updates updaters', ->
      updater1Updated = false
      updater2Updated = false
      t = new TestController(
        null, null, null
        null, null
        (dt) -> updater1Updated = true; expect(dt).to.equal(1)
        (dt) -> updater2Updated = true; expect(dt).to.equal(1)
      )
      expect(updater1Updated).to.be.false
      expect(updater2Updated).to.be.false
      t.onEnter()
      t.update(1)
      expect(updater1Updated).to.be.true
      expect(updater2Updated).to.be.true


describe 'Model', ->
  class TestModel extends kaniku.Model
    @defaults
      x: 1
      y: 2
      z: 3

  describe 'constructor', ->
    it 'creates new object with defaults', ->
      t = new TestModel
      expect(t.getX()).to.equal(1)
      expect(t.getY()).to.equal(2)
      expect(t.getZ()).to.equal(3)

    it 'can override defaults', ->
      t = new TestModel(x: 111, y: 222)
      expect(t.getX()).to.equal(111)
      expect(t.getY()).to.equal(222)
      expect(t.getZ()).to.equal(3)

  describe '.defaults', ->
    it 'sets defaults', ->
      t = new TestModel()
      expect(t.getX()).to.equal(1)
      expect(t.getY()).to.equal(2)
      expect(t.getZ()).to.equal(3)

    it 'creates getters and setters', ->
      t = new TestModel
      expect(t).to.respondTo('getX')
      expect(t).to.respondTo('setX')
      expect(t).to.respondTo('getY')
      expect(t).to.respondTo('setY')
      expect(t).to.respondTo('getZ')
      expect(t).to.respondTo('setZ')

    it 'create getters and setters property-style', ->
      t = new TestModel(x: 111)
      expect(t).to.ownProperty('x')
      expect(t).to.ownProperty('y')
      expect(t).to.ownProperty('z')
      t.y = 111
      expect(t.x).to.equal(111)
      expect(t.y).to.equal(222)
      expect(t.z).to.equal(3)

  describe 'getters and setters', ->
    it 'emit event on change', ->
      t = new TestModel
      listenerExecutedX = false
      listenerExecutedY = false
      listenerExecutedZ = false
      t.on 'change:x', ->
        listenerExecutedX = true
      t.on 'change:y', ->
        listenerExecutedY = true
      t.on 'change:z', ->
        listenerExecutedZ = true

      expect(listenerExecutedX).to.be.false
      expect(listenerExecutedY).to.be.false
      expect(listenerExecutedZ).to.be.false

      t.setX(111)
      t.y = 222

      expect(listenerExecutedX).to.be.true
      expect(listenerExecutedY).to.be.true
      expect(listenerExecutedZ).to.be.false

    it 'emit event on change of computed properties', ->
      class T extends TestModel
        @computed 'getW', depends: ['x', 'y']
        getW: ->
          @getX() + @getY()

      t = new T
      listenerExecuted = false
      t.on 'change:w', ->
        listenerExecuted = true

      expect(listenerExecuted).to.be.false
      t.setX(111)
      expect(listenerExecuted).to.be.true

  describe '.getDefaults', ->
    it 'returns object supplied to .defaults method', ->
      expect(TestModel.getDefaults()).to.eql({x: 1, y: 2, z: 3})

    it 'returns empty object when no defaults available', ->
      class T extends kaniku.Model
      expect(T.getDefaults()).to.eql({})

  describe '.useUpdates', ->
    it 'makes #needsUpdating return true or false', ->
      class T1 extends kaniku.Model
      class T2 extends kaniku.Model
        @useUpdates()
      class T3 extends T2
        @useUpdates(false)

      t1 = new T1
      t2 = new T2
      t3 = new T3
      expect(t1.needsUpdating()).to.be.false
      expect(t2.needsUpdating()).to.be.true
      expect(t3.needsUpdating()).to.be.false

  describe '#on', ->
    it 'registers listener', ->
      t = new TestModel
      f = ->
      t.on('test-event', f)
      expect(t._listeners['test-event']).to.exist()
      expect(t._listeners['test-event']).to.include(f)

  describe '#removeListener', ->
    it 'unregisters listener', ->
      t = new TestModel
      f = ->
      t.on('test-event', f)
      expect(t._listeners['test-event']).to.include(f)
      t.removeListener('test-event', f)
      expect(t._listeners['test-event']).not.to.include(f)

  describe '#emit', ->
    it 'sends data to listeners', ->
      t = new TestModel

      receivedEvent = null
      t.on 'test-event', (event) ->
        receivedEvent = event

      t.emit('test-event', {ok: true})
      expect(receivedEvent).to.eql({ok: true})

    it 'supports event hierarchy', ->
      t = new TestModel

      receivedEvent1 = null
      receivedEvent2 = null
      receivedEvent3 = null
      t.on 'namespace1:namespace2:test-event', (event) ->
        receivedEvent1 = event
      t.on 'namespace1:namespace2', (event) ->
        receivedEvent2 = event
      t.on 'namespace1', (event) ->
        receivedEvent3 = event

      t.emit('namespace1:namespace2:test-event', {ok: true})

      expect(receivedEvent1).to.eql({ok: true})
      expect(receivedEvent2).to.eql({ok: true})
      expect(receivedEvent3).to.eql({ok: true})

  describe '#getDefaults', ->
    it 'returns object supplied to .defaults method', ->
      t = new TestModel
      expect(t.getDefaults()).to.eql({x: 1, y: 2, z: 3})

    it 'returns empty object when no defaults available', ->
      class T extends kaniku.Model
      t = new T
      expect(t.getDefaults()).to.eql({})

  describe '#getData', ->
    it 'returns defaults if object is not changed', ->
      t = new TestModel
      expect(t.getData()).to.eql({x: 1, y: 2, z: 3})

    it 'returns defaults and applied changes', ->
      t = new TestModel(x: 111)
      t.setY(222)
      expect(t.getData()).to.eql({x: 111, y: 222, z: 3})

    it 'includes computed properties', ->
      class T extends TestModel
        @computed 'getW', depends: ['x', 'y']
        getW: ->
          @getX() + @getY()

      t = new T(x: 111)
      t.setY(222)
      expect(t.getData()).to.eql({x: 111, y: 222, z: 3, w: 333})
