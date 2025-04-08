<script lang="ts">
  import app from '#app/app'
  import { icon as iconFn } from '#app/lib/icons'
  import { isOpenedOutside } from '#app/lib/utils'
  import { assertString } from '../assert_types'

  export let url
  export let text = null
  export let html = null
  export let icon = null
  export let title = ''
  export let light = false
  export let dark = false
  export let grey = false
  export let classNames = null
  export let tinyButton = false
  export let stopClickPropagation = true

  assertString(url)

  const isExternalLink = url?.[0] !== '/'
  let target, rel
  if (isExternalLink) {
    target = '_blank'
    rel = 'noopener'
  }

  if (text && !title) title = text

  function onClick (e) {
    if (stopClickPropagation) e.stopPropagation()
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
  <!-- #if blocks are inlined to avoid the insertion of undesired spaces -->
  {#if icon}{@html iconFn(icon)}{/if}{#if html}
    {@html html}
  {:else if text}
    <span class="link-text">{text}</span>
  {/if}
</a>

<style lang="scss">
  @use "#general/scss/utils";

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
