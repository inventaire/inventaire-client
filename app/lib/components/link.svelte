<script>
  import { isOpenedOutside } from 'lib/utils'

  export let url, text, title = '', light = false

  const isExternalLink = url[0] !== '/'
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
  on:click={onClick}
  >
  {text}
</a>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  a.light{
    @include link-light;
  }
</style>
