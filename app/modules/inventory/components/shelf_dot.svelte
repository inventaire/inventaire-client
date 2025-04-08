<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { getColorHexCodeFromCouchUuId } from '#app/lib/images/images'
  import { viewportIsSmallerThan } from '#app/lib/screen'
  import { isOpenedOutside } from '#app/lib/utils'

  export let shelf

  const { name, _id } = shelf

  const colorHexCode = shelf.color || `#${getColorHexCodeFromCouchUuId(_id)}`

  const dispatch = createEventDispatcher()

  function onShelfDotClick (e) {
    if (isOpenedOutside(e)) return
    dispatch('selectShelf', { shelf })
    e.preventDefault()
  }
</script>
<li>
  {#if viewportIsSmallerThan(600)}
    <div
      class="shelf-dot"
      title={name}
      style:background-color={colorHexCode}
    ></div>
  {:else}
    <a
      href="/shelves/{_id}"
      on:click={onShelfDotClick}
      title={name}
      aria-label={name}
    >
      <div
        class="shelf-dot"
        style:background-color={colorHexCode}
      ></div>
    </a>
  {/if}
</li>
<style lang="scss">
  @use "#general/scss/utils";

  .shelf-dot{
    @include radius;
    width: 1em;
    height: 1em;
    margin: 0.3em;
  }

  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .shelf-dot{
      margin: 0.2em;
    }
  }
</style>
