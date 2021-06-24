<script>
  import { icon } from 'app/lib/utils'
  import log_ from 'lib/loggers'
  import Spinner from 'modules/general/components/spinner.svelte'
  import { I18n } from 'modules/user/lib/i18n'

  export let state
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
        {@html state.message || I18n('loading')}
      {:else}
        {#if iconName}{@html icon(iconName)}{/if}
        {@html state.message}
      {/if}
    </div>
    <button on:click={() => state = null}>
      {@html icon('close')}
    </button>
  </div>
{/if}

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .flash{
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    padding: 0.3em;
    padding-left: 0.5em;
    button{
      padding: 0;
    }
  }
  .error{
    background-color: lighten($danger-color, 30%);
    color: darken($danger-color, 20%);
    button{
      color: darken($danger-color, 20%);
    };
  }
  .success{
    background-color: lighten($success-color, 30%);
    color: darken($success-color, 20%);
    button{
      color: darken($success-color, 20%);
    };
  }
  .info, .loading{
    background-color: lighten($primary-color, 70%);
    color: $primary-color;
    button{
      color: $primary-color;
    };
  }
  .warning{
    background-color: lighten($yellow, 30%);
    color: darken($success-color, 70%);
    button{
      color: darken($success-color, 70%);
    };
  }
</style>
