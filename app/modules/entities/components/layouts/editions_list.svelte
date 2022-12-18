<script>
  import { I18n } from '#user/lib/i18n'
  import EditionsListActions from './editions_list_actions.svelte'
  import EntitiesList from './entities_list.svelte'
  import EditionCreation from './edition_creation.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let hasSomeInitialEditions,
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
    {#if isNonEmptyArray(initialEditions)}
      <span
        class="counter"
        title={I18n('all_editions_count', { smart_count: initialEditions.length })}
      >
        {initialEditions.length}
      </span>
    {/if}
  </div>
  {#if hasSomeInitialEditions}
    {#if initialEditions.length > 1}
      <EditionsListActions
        bind:editions
        {initialEditions}
        {someEditions}
      />
    {/if}
    <EntitiesList
      entities={editions}
      relatedEntities={publishersByUris}
      {parentEntity}
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
  @import "#general/scss/utils";

  .editions-section{
    @include display-flex(column, center);
    @include radius;
    padding: 0.5em;
    width: 100%;
    background-color: $off-white;
  }
  .editions-list-title{
    @include display-flex(row, center, center);
    margin-bottom: 0.5em;
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
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .editions-section{
      padding: 1em;
    }
  }
</style>
