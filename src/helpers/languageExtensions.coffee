Function::property = (prop, desc) ->
  Object.defineProperty @::, prop, desc
