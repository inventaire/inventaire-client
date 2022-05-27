<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  export let show = false,
    moreText,
    lessText,
    scrollTopElement,
    reversedShow

  function toggle () {
    show = !show
    if (!show && scrollTopElement) {
      scrollTopElement.scrollIntoView({ behavior: 'smooth' })
    }
  }

  const notShowData = {
    chevron: reversedShow ? 'up' : 'down',
    text: reversedShow ? lessText : moreText
  }
  const showData = {
    chevron: reversedShow ? 'down' : 'up',
    text: reversedShow ? moreText : lessText
  }
</script>

{#if show}
  {#if lessText}
    <button
      class="wrap-toggler"
      on:click={toggle}
      >
      {@html icon(`chevron-${showData.chevron}`)}
      {showData.text}
    </button>
  {/if}
{:else}
  <button
    class="wrap-toggler"
    on:click={toggle}
    >
    {@html icon(`chevron-${notShowData.chevron}`)}
    {notShowData.text}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  button{
    display: block;
    @include shy;
  }
</style>
