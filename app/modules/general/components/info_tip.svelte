<script>
  import { icon } from '#lib/handlebars_helpers/icons'

  export let text
  let showInfoText = false

  const toggleInfoText = () => showInfoText = !showInfoText
  const hideInfoText = () => showInfoText = false
</script>

<div
  class="wrapper"
  on:click|stopPropagation
  >
  <button
    title={text}
    on:click={toggleInfoText}
    >
    {@html icon('question-circle')}
  </button>
  {#if showInfoText}
    <span class="info-text">{text}</span>
  {/if}
</div>

<svelte:body on:click={hideInfoText} />

<style lang="scss">
  @import '#general/scss/utils';

  $infotip-bg-color: $light-grey;
  $infotip-text-line-height: 1.4rem;
  $spike-size: 0.5rem;

  button{
    padding: 0.2rem;
  }
  .wrapper{
    display: inline-block;
    position: relative;
  }
  .info-text{
    position: absolute;
    background-color: $infotip-bg-color;
    margin-top: -0.2rem;
    margin-right: 0.3rem;
    padding: 0.2rem 0.5rem;
    min-width: 10em;
    z-index: 1;
    @include radius-right;
    // Arrow
    &:after{
      content: '';
      position: absolute;
      left: 0;
      top: 0.5rem;
      margin-left: -0.5rem;
      width: 0;
      height: 0;
      border-right: $spike-size solid $infotip-bg-color;
      border-top: $spike-size solid transparent;
      border-bottom: $spike-size solid transparent;
    }
  }
</style>
