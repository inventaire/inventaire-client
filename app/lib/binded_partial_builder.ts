export default (context, functionName) => (...partialArgs) => {
  // return a function binded to a context and possibly some arguments
  return (...remainingArgs) => context[functionName](...partialArgs, ...remainingArgs)
}
