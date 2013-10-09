Function::property = (prop, desc) ->
  Object.defineProperty @::, prop, desc
Function::classProperty = (prop, desc) ->
  Object.defineProperty @, prop, desc
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
    fn.apply @, args
String::capitaliseFirstLetter = ->
  return @ if @length is 0
  return @toUpperCase() if @length is 1
  @charAt(0).toUpperCase() + @slice(1)
