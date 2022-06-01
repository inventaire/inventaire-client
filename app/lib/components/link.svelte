<script>
  import { isOpenedOutside } from '#lib/utils'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'

  export let url, text, icon = null, title = '', light = false, dark = false

  const isExternalLink = url?.[0] !== '/'
  let target, rel
  if (isExternalLink) {
    target = '_blank'
    rel = 'noopener'
  }

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
  on:click={onClick}
  >
  {#if icon}{@html iconFn(icon)}{/if}
  {text}
</a>

<style lang="scss">
  @import '#general/scss/utils';

  a.light{
    @include link-light;
  }
  a.dark{
    @include link-dark;
  }
</style>
