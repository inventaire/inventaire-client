<script lang="ts">
  import { fade } from 'svelte/transition'
  import { icon } from '#app/lib/icons'
  import { wait } from '#app/lib/promises'
  import { i18n } from '#user/lib/i18n'

  export let text: string
  export let buttonTitle = ''
  export let classes = ''

  let copiedText = false
  async function copyToClipBoard () {
    navigator.clipboard.writeText(text)
    copiedText = true
    await wait(800)
    copiedText = false
  }
</script>

<button
  on:click={() => copyToClipBoard()}
  class={classes}
  title={buttonTitle}
>
  {text}
  {#if copiedText}
    <span class="confirmation" transition:fade={{ duration: 200 }} role="status">
      {@html icon('check')}
      {i18n('Copied')}
    </span>
  {/if}
</button>

<style lang="scss">
  @import '#general/scss/utils';
  .confirmation{
    color: $success-color;
    text-decoration: none;
  }
</style>
