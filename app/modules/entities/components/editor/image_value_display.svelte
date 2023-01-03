<script>
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let value, property

  const dispatch = createEventDispatcher()
</script>

<button class="value-display" on:click={() => dispatch('edit')} title={I18n('edit')}>
  {#if value}
    <img src={imgSrc(`/img/entities/${value}`, 300, 300)} alt={I18n(property)} />
  {/if}
</button>

<style lang="scss">
  @import '#general/scss/utils';

  .value-display{
    flex: 1;
    align-self: stretch;
    @include bg-hover(white, 5%);
  }
  img{
    display: block;
    margin-right: auto;
  }
</style>
