<script>
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'

  export let value

  const dispatch = createEventDispatcher()
</script>

<button class="value-display" on:click={() => dispatch('edit')} title={I18n('edit')}>
  {value || ''}
</button>

<style lang="scss">
  @import "#general/scss/utils";

  .value-display{
    flex: 1;
    align-self: stretch;
    cursor: pointer;
    text-align: left;
    @include bg-hover(white, 5%);
    user-select: text;
    font-weight: normal;
  }
</style>
