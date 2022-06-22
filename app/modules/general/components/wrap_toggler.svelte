<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  export let show = false,
    moreText,
    lessText,
    scrollTopElement,
    reversedShow,
    withIcon = true

  function toggle () {
    show = !show
    if (!show && scrollTopElement) {
      scrollTopElement.scrollIntoView({ behavior: 'smooth' })
    }
  }

  const showLessData = {
    chevron: reversedShow ? 'up' : 'down',
    text: reversedShow ? lessText : moreText
  }
  const showMoreData = {
    chevron: reversedShow ? 'down' : 'up',
    text: reversedShow ? moreText : lessText
  }
</script>

{#if show}
  {#if lessText}
    <button
      class="wrap-toggler"
      on:click|stopPropagation={toggle}
      >
      {#if withIcon}
        {@html icon(`chevron-${showMoreData.chevron}`)}
      {/if}
      {showMoreData.text}
    </button>
  {/if}
{:else}
  <button
    class="wrap-toggler"
    on:click|stopPropagation={toggle}
    >
    {#if withIcon}
      {@html icon(`chevron-${showLessData.chevron}`)}
    {/if}
    {showLessData.text}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  button{
    display: block;
    @include shy;
  }
</style>
