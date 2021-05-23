<script>
  let flashPriority, flashMessage, hidden = 'hidden'
  import { icon } from 'app/lib/utils'
  export const show = ({ priority, message }) => {
    flashPriority = priority
    flashMessage = message
    hidden = ''
  }
  export const hide = () => hidden = 'hidden'
</script>
<div class="flash {flashPriority} {hidden}">
  <span>
    {#if flashPriority === 'success'}
      {@html icon('check')}
    {/if}
    {flashMessage}
  </span>
  <button on:click="{hide}">
    {@html icon('close')}
  </button>
</div>

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
  .hidden{
    display: none;
  }
</style>
