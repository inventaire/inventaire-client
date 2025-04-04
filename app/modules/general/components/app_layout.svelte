<script lang="ts">
  import type { RegionComponent } from '#app/init_app_layout'
  import { commands, vent } from '#app/radio'
  import { preventFormSubmit } from '#general/lib/prevent_form_submit'
  import DocumentHeaders from './document_headers.svelte'
  import FullScreenLoader from './full_screen_loader.svelte'
  import GlobalFlashMessage from './global_flash_message.svelte'
  import Modal from './modal.svelte'
  import TopBar from './top_bar.svelte'

  export let main: RegionComponent = null
  export let modal: RegionComponent = null
  export let svelteModal: RegionComponent = null

  // Unfortunately, setting class:hasOverlay on <svelte:body> doesn't work
  // See https://github.com/sveltejs/svelte/issues/3105
  vent.on('overlay:shown', () => document.body.classList.add('hasOverlay'))
  vent.on('overlay:hidden', () => document.body.classList.remove('hasOverlay'))

  let showModal = false
  let modalSize
  commands.setHandlers({
    'modal:open': (size?: 'large' | 'medium') => {
      showModal = true
      modalSize = size
    },
    'modal:close': () => {
      showModal = false
      modalSize = undefined
    },
    'show:loader': () => main = null,
  })

  $: main ??= { component: FullScreenLoader, props: {} }
</script>

<DocumentHeaders />

<div class="top-bar">
  <TopBar />
</div>

<main id="main">
  {#if main}
    <svelte:component this={main.component} {...main.props} />
  {/if}
</main>

{#if showModal && modal}
  <div class="modal-wrapper">
    <Modal size={modalSize} on:closeModal={() => showModal = false}>
      <svelte:component this={modal.component} {...modal.props} />
    </Modal>
  </div>
{/if}

{#if svelteModal}
  <svelte:component this={svelteModal.component} {...svelteModal.props} />
{/if}

<GlobalFlashMessage />

<svelte:body on:submit={preventFormSubmit} />

<style lang="scss">
  @import '#general/scss/utils';

  .top-bar{
    // Required to set a z-index
    position: relative;
    // Make the top bar appear above main
    z-index: 1;
  }

  :global(main){
    position: relative;
    z-index: 0;
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    :global(main){
      // Allow scrollToElement to really get the top of the div
      // at the top of the screen, which would not be possible
      // if main was smaller than the screen
      min-height: calc(100vh - $topbar-height);
    }
    :global(main.active-connection-button){
      margin-block-end: $smallscreen-connection-buttons-height;
    }
  }

  @media screen and (height >= $top-bar-fixed-threshold){
    :global(main){
      // Prevent children margin-top to be collapsed with that margin-top
      // by setting a border, so that children margin-top start from that border
      // See https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Box_Model/Mastering_margin_collapsing
      border-block-start: 1px solid transparent;
      margin-block-start: calc($topbar-height - 1px);
    }
  }

  .modal-wrapper{
    z-index: 2;
  }

  :global(body.hasOverlay .top-bar){
    z-index: 0;
    background-color: red !important;
    // It would also be possible to disable body scroll to let the scroll monopoly to the overlay
    // but that would loose the scroll level when closing the overlay
    // overflow: hidden;
    // max-height: 100vh;
  }
</style>
