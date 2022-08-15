<script>
  import { cutBeforeWord } from '#lib/utils'

  export let text
  export let maxLength = 200

  $: displayedText = cutBeforeWord(text, maxLength)
</script>

<p>
  {displayedText}
  {#if displayedText.length < text.length}
    …
    <slot name="more" />
  {/if}
</p>
