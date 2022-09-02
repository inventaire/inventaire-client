import { createEventDispatcher } from 'svelte'

export const BubbleUpComponentEvent = dispatch => {
  dispatch = dispatch || createEventDispatcher()
  return e => {
    if (e instanceof CustomEvent) {
      // Assumes that this e.detail is the DOM event to bubble-up
      dispatch(e.type, e.detail)
    } else {
      // Assumes that e is the DOM event to bubble-up
      dispatch(e.type, e)
    }
  }
}

// Use to make reactive statements code more explicit:
// Ex: allows to replace:
//     $: someVariable != null && doSomething()     // Not possible for variables that could actually == null
//     $: if (someVariable != null) doSomething()   // Not possible for variables that could actually == null
//     $: if (someVariable || true) doSomething()
// with:
//     $: onChange(someVariable, doSomething)
//     $: onChange(someVariable, someOtherVariable, doSomething)
// The syntax is tought to invite wrapping other variables
// for which we should NOT watch for change in the callback,
// so that they don't trigger the reactive execution
export const onChange = (...args) => {
  const callback = args.slice(-1)[0]
  callback()
}
