<script lang="ts">
  import { uniqueId } from 'underscore'
  import { icon } from '#app/lib/icons'

  export let text
  let showInfoText = false
  const infotipId = uniqueId('infotip')

  const toggleInfoText = () => showInfoText = !showInfoText
  const hideInfoText = () => showInfoText = false
</script>

<button
  title={text}
  aria-controls={infotipId}
  on:click|stopPropagation={toggleInfoText}
>
  {@html icon('question-circle')}
</button>

{#if showInfoText}
  <p
    id={infotipId}
    class="info-text"
  >
    {text}
  </p>
{/if}

<svelte:body on:click={hideInfoText} />

<style lang="scss">
  @import "#general/scss/utils";
  button{
    padding: 0 0.2rem;
    margin: 0 0.2rem;
    @include shy;
  }
  .info-text{
    display: inline-block;
    line-height: 1.1rem;
    padding: 0.2rem;
    color: $label-grey;
  }
</style>
