Function::property = (prop, desc) ->
  Object.defineProperty @::, prop, desc
Function::partial = ->
  fn = @
  partiallyAppliedArgs = Array::slice.call arguments
  ->
    args = []
    pushedArgs = 0
    for partiallyAppliedArg in partiallyAppliedArgs
      if partiallyAppliedArg is undefined
        args.push arguments[pushedArgs++]
      else
        args.push partiallyAppliedArg
    if arguments.length > pushedArgs
      for i in [pushedArgs..arguments.length - 1]
        args.push arguments[i]
    console.log args
    fn.apply @, args
