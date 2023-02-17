<script>
  import { isOpenedOutside } from '#lib/utils'
  import { loadShelfLink } from '#shelves/components/lib/shelves'
  import { getColorHexCodeFromModelId } from '#lib/images'
  import { viewportIsSmallerThan } from '#lib/screen'

  export let shelf

  const { name, _id } = shelf

  const colorHexCode = shelf.color || `#${getColorHexCodeFromModelId(_id)}`

  function onShelfDotClick (e) {
    if (isOpenedOutside(e)) return
    loadShelfLink(shelf)
    e.preventDefault()
  }
</script>
<li>
  {#if viewportIsSmallerThan(600)}
    <div
      class="shelf-dot"
      title={name}
      style:background-color={colorHexCode}
    />
  {:else}
    <a
      href="/shelves/{_id}"
      on:click={onShelfDotClick}
      title={name}
    >
      <div
        class="shelf-dot"
        style:background-color={colorHexCode}
      />
    </a>
  {/if}
</li>
<style lang="scss">
  @import "#general/scss/utils";

  .shelf-dot{
    @include radius;
    width: 1em;
    height: 1em;
    margin: 0.3em;
  }

  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    .shelf-dot{
      margin: 0.2em;
    }
  }
</style>
