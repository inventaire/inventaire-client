import { createEventDispatcher } from 'svelte'

export function BubbleUpComponentEvent (dispatch?: ReturnType<typeof createEventDispatcher>) {
  dispatch = dispatch || createEventDispatcher()
  return e => {
    if (e instanceof CustomEvent) {
      // Re-dispatch an identical custom event
      dispatch(e.type, e.detail)
    } else {
      // 'e' is expected to be a DOM event
      // Dispatch the event object as event detail to make its attributes,
      // such as its `target` accessible to parent components
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
export function onChange (...args) {
  const callback = args.slice(-1)[0]
  callback()
}
