class Persistor

  constructor: (@storage, @baseKey) ->
    @usingDummyStorage = not @storage?
    if @usingDummyStorage then @storage =
      setItem: (key, value) -> @[key] = value
      getItem: (key) -> @[key]

  _key: (localKey) -> "#{@baseKey}.#{localKey}"

  set: (localKey, value) ->
    @storage.setItem @_key(localKey), value

  get: (localKey, defaultValue) ->
    value = @storage.getItem @_key(localKey)
    value ? defaultValue




root = exports ? window
root.Persistor = Persistor