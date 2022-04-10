<script>
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher, onDestroy } from 'svelte'

  const dispatch = createEventDispatcher()
  const close = () => dispatch('close')

  let modal

  // from https://svelte.dev/examples/modal
  const handleKeydown = e => {
    if (e.key === 'Escape') {
      close()
      return
    }
    if (e.key === 'Tab') {
      // trap focus
      const nodes = modal.querySelectorAll('*')
      const tabbable = Array.from(nodes).filter(n => n.tabIndex >= 0)

      let index = tabbable.indexOf(document.activeElement)
      if (index === -1 && e.shiftKey) index = 0

      index += tabbable.length + (e.shiftKey ? -1 : 1)
      index %= tabbable.length

      tabbable[index].focus()
      e.preventDefault()
    }
  }

  const previouslyFocused = document.activeElement
  if (previouslyFocused) {
    onDestroy(() => {
      previouslyFocused.focus()
    })
  }
</script>
<svelte:window on:keydown={handleKeydown}/>
<div
  class="modal-background"
  on:click={close}
/>
<div
  class="modal-wrapper"
  on:click={close}
>
<div
  bind:this={modal}
  class="modal"
  role="dialog"
  aria-modal="true"
>
  <div class="close-wrapper">
    <button
      on:click={close}
      class="close-button"
      title="{i18n('close')}"
    >
      ×
    </button>
  </div>
  <div class="modal-content">
    <slot></slot>
  </div>
</div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  @import '#general/scss/_modal';
  .modal-background {
    background: rgba(black, 0.4);
    @include position(fixed, 0, 0, 0, 0);
  }
  .modal-wrapper{
    position: fixed;
    width: 100%;
    top:  5em;
    right: 0;
  }
  .modal {
    @include display-flex(row-reverse, flex-start, flex-end);
    z-index: 1;
    overflow: auto;
    padding: 0 1em;
  }
  .modal-content{
    padding: 1em;
    overflow: auto;
    box-shadow: 3px 3px 10px 3px rgba(#222, 0.5);
    background-color: white;

  }
  .close-wrapper{
    margin-left: 1em;
  }
  .close-button{
    @include shy(0.9);
    @include radius;
    position: relative;
    top: 10px;
    right: 10px;
    padding: 0;
    line-height: 0;
    font-size: 3.6rem;
    font-weight: bold;
    color: white;
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .modal-wrapper{
      left: 0;
      width: 100%;
    }
    .modal{
      background-color: yellow;
      @include display-flex(column, flex-end, stretch);
      padding: 0 1em;
      width: 100%;
    }
    .modal-content{
      @include radius;
      padding: 1em 0;
    }
    .close-button{
      margin-bottom: 0.5em;
    }
    .close-wrapper{
      margin : 0.5em 0;
    }
  }
  /*Medium / Large screens*/
  /*@media screen and (min-width: $smaller-screen) {*/
  @media screen and (min-width: 1000px) {
    .modal{
    background-color: green;
    }
    .modal-wrapper{
    }
  }
  /*Large screens*/
  @media screen and (min-width: 1800px) {
    .modal{
    }
  }
</style>