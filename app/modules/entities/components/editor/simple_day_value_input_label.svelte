<script>
  import { I18n } from 'modules/user/lib/i18n'
  export let value, name, optional = true, closeButtonTitle
</script>

{#if value || !optional}
  <div>
    <label for="{name}">{I18n(name)}</label>
    {#if optional}
      <button
        class="close"
        title={closeButtonTitle}
        on:click={() => value = null}
      >
      &#215;
      </button>
    {/if}
  </div>
{/if}

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  div{
    margin-bottom: 0.1em;
    height: 1.5rem;
    width: 5rem;
    margin-right: 0.5em;
    @include display-flex(row, center, flex-start);
  }
  .close{
    font-size: 1.5rem;
    margin: 0 0 0 auto;
    padding: 0;
    line-height: 0;
    height: 100%;
    width: 1.5rem;
    @include shy(0.8);
    @include bg-hover(white);
  }
</style>
