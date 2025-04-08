<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { I18n } from '#user/lib/i18n'

  export let value

  const dispatch = createEventDispatcher()
</script>

<button class="value-display" on:click={() => dispatch('edit')} title={I18n('edit')}>
  {value || ''}
</button>

<style lang="scss">
  @use "#general/scss/utils";

  .value-display{
    flex: 1;
    align-self: stretch;
    cursor: pointer;
    text-align: start;
    @include bg-hover(white, 5%);
    user-select: text;
    font-weight: normal;
  }
</style>
