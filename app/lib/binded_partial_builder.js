/* eslint-disable
    no-return-assign,
    no-unused-vars,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default function (context, functionName) {
  let BindedPartial
  return BindedPartial = function (...args) {
    args.unshift(context)
    // return a function binded to a context and possibly some arguments
    return context[functionName].bind.apply(context[functionName], args)
  }
};
