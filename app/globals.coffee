global.dealWith = (err) ->
  if err
    console.error err.stack
    throw err
