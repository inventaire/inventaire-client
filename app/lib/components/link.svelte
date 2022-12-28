<script>
  import { isOpenedOutside } from '#lib/utils'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'

  export let url, text, html, icon = null, title = '', light = false, dark = false, grey = false, classNames, tinyButton = false

  const isExternalLink = url?.[0] !== '/'
  let target, rel
  if (isExternalLink) {
    target = '_blank'
    rel = 'noopener'
  }

  if (text && !title) title = text

  function onClick (e) {
    e.stopPropagation()
    if (!(isExternalLink || isOpenedOutside(e))) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }
</script>

<a
  href={url}
  {title}
  {target}
  {rel}
  class:light
  class:dark
  class:grey
  class:tiny-button={tinyButton}
  class={classNames}
  on:click={onClick}
>
  {#if icon}{@html iconFn(icon)}{/if}
  {#if html}
    {@html html}
  {:else}
    <span class="link-text">{text}</span>
  {/if}
</a>

<style lang="scss">
  @import '#general/scss/utils';

  a:not(.tiny-button){
    &.light{
      @include link-light;
    }
    &.dark{
      @include link-dark;
    }
    &.grey{
      @include link-underline-on-hover($grey, $dark-grey);
    }
  }
</style>
