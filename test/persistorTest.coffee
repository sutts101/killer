{Persistor} = require '../src/persistor'

chai = require 'chai'
chai.should()

class FakeStorage

  setItem: (key, value) -> @[key] = value

  getItem: (key) -> @[key]

describe "Persistor", ->

  persistors = null

  beforeEach ->
    persistors = [
      new Persistor new FakeStorage, 'home'
      new Persistor undefined, 'home'
    ]
    for persistor in persistors
      persistor.set 'fruit', 'banana'
      persistor.set 'color', 'green'

  it "should retrieve a value that was previously set", ->
    persistor.get('fruit').should.equal 'banana' for persistor in persistors

  it "should return undefined where value not set", ->
    (persistor.get('vegetable') is undefined).should.equal true for persistor in persistors

  it "should return default value where supplied and value not previously set", ->
    persistor.get('vegetable', 'turnip').should.equal 'turnip' for persistor in persistors

  it "should know whether it is using injected or dummy storage", ->
    persistors[0].usingDummyStorage.should.equal false
    persistors[1].usingDummyStorage.should.equal true

