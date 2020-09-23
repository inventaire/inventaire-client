module.exports = (context, functionName)->
  return BindedPartial = (args...)->
    args.unshift context
    # return a function binded to a context and possibly some arguments
    return context[functionName].bind.apply context[functionName], args
