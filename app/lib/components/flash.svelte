<script>
  import { icon } from '#lib/utils'
  import log_ from '#lib/loggers'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'

  export let state = null
  let type, iconName
  const types = {
    success: { iconName: 'check' },
    info: { iconName: 'info-circle' },
    error: { iconName: 'warning' }
  }

  const findIcon = type => types[type]?.iconName
  $: {
    if (state instanceof Error) {
      type = 'error'
      iconName = findIcon(type)
      // Logs the error and report it
      log_.error(state)
    } else {
      type = state?.type
      iconName = findIcon(type)
    }
  }
</script>

{#if state}
  <div class="flash {type}">
    <div>
      {#if type === 'loading'}
        <Spinner/>
        {state.message || I18n('loading')}
      {:else}
        {#if iconName}{@html icon(iconName)}{/if}
        {state.message}
      {/if}
    </div>
    <button on:click="{() => state = null}" title="{ I18n('close') }">
      {@html icon('close')}
    </button>
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .flash{
    @include display-flex(row, flex-start, space-between);
    padding: 0.5em;
    margin: 0.3em 0;
    padding-left: 0.5em;
    color: $dark-grey;
    @include radius;
    button{
      margin: 0.2em;
      padding: 0;
    }
  }
  .error{
    background-color: lighten($danger-color, 25%);
  }
  .success{
    background-color: lighten($success-color, 30%);
  }
  .info, .loading{
    background-color: lighten($primary-color, 70%);
  }
  .warning{
    background-color: lighten($yellow, 35%);
  }
</style>
