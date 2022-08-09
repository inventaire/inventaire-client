<script>
  import { I18n } from '#user/lib/i18n'
  import EditionsListActions from './editions_list_actions.svelte'
  import EntitiesList from './entities_list.svelte'
  import EditionCreation from './edition_creation.svelte'

  export let someInitialEditions,
    someEditions,
    editions,
    publishersByUris,
    parentEntity,
    initialEditions,
    itemsByEditions
</script>
<div class="editions-section">
  <div class="editions-list-title">
    <h5>
      {I18n('editions')}
    </h5>
    <span class="counter">{initialEditions.length}</span>
  </div>
  <EditionsListActions
    bind:editions={editions}
    {initialEditions}
    {someInitialEditions}
    {someEditions}
  />
  {#if someInitialEditions}
    <EntitiesList
      entities={editions}
      relatedEntities={publishersByUris}
      {parentEntity}
      type='editions'
      itemsByEditions={itemsByEditions}
    />
  {:else}
    <div class="no-edition-wrapper">
      {I18n('no editions found')}
    </div>
  {/if}
  <EditionCreation
    work={parentEntity}
    bind:editions={initialEditions}
  />
</div>
<style lang="scss">
  @import '#general/scss/utils';

  .editions-section{
    @include display-flex(column, center);
    @include radius;
    padding: 0.5em;
    width: 100%;
    background-color: $off-white;
  }
  .editions-list-title{
    @include display-flex(row, center, center);
    h5{
      @include sans-serif;
      margin-bottom: 0;
    }
    .counter{
      line-height: 1em;
      margin: 0 0.5em;
      padding: 0.2em 0.5em;
      background-color: white;
      @include radius;
    }
  }
  .no-edition-wrapper{
    @include display-flex(row, center, center);
    color: $grey;
    margin-top: 1em;
  }
</style>
