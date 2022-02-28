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
