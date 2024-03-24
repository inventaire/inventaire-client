export default (context, functionName) => (...args) => {
  args.unshift(context)
  // return a function binded to a context and possibly some arguments
  return context[functionName].bind.apply(context[functionName], args)
}
