<script>
  import { icon } from 'app/lib/utils'
  import log_ from 'lib/loggers'
  export let state
  let flashPriority, iconName
  $: {
    if (state instanceof Error) {
      flashPriority = 'error'
      iconName = 'warning'
      // Logs the error and report it
      log_.error(state)
    } else {
      flashPriority = state?.priority
      iconName = flashPriority === 'success' ? 'check' : null
    }
  }
</script>

{#if state}
  <div class="flash {flashPriority}">
    <span>
      {#if iconName}{@html icon(iconName)}{/if}
      {state.message}
    </span>
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
  .info{
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
