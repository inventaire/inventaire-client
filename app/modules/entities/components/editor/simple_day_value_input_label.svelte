<script lang="ts">
  import { i18n, I18n } from '#user/lib/i18n'

  export let value
  export let name: string
  export let optional = true
  export let componentId: string
</script>

{#if value || !optional}
  <div>
    <label for={name}>{I18n(name)}</label>
    {#if optional}
      <button
        class="close"
        aria-controls="{componentId}-{name}"
        title={i18n(`Remove ${name} precision`)}
        on:click={() => value = null}
      >
        &#215;
      </button>
    {/if}
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  div{
    margin-block-end: 0.1em;
    block-size: 1.5rem;
    inline-size: 5rem;
    margin-inline-end: 0.5em;
    @include display-flex(row, center, flex-start);
  }
  .close{
    font-size: 1.5rem;
    margin: 0 0 0 auto;
    padding: 0;
    line-height: 0;
    block-size: 100%;
    inline-size: 1.5rem;
    @include shy(0.8);
    @include bg-hover(white);
  }
</style>
