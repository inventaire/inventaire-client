<script lang="ts">
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import type { SerializedEntitiesByUris, SerializedEntity } from '#entities/lib/entities'
  import { I18n } from '#user/lib/i18n'
  import EditionCreation from './edition_creation.svelte'
  import EditionsListActions from './editions_list_actions.svelte'
  import EntitiesList from './entities_list.svelte'
  import type { ItemsByEditions } from './edition_actions.svelte'

  export let hasSomeInitialEditions = false
  export let editions: SerializedEntity[]
  export let publishersByUris: SerializedEntitiesByUris
  export let parentEntity: SerializedEntity
  export let initialEditions: SerializedEntity[]
  export let waitingForItems = null
  export let itemsByEditions: ItemsByEditions = {}

  const { loggedIn } = app.user
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
        {waitingForItems}
      />
    {/if}
    <EntitiesList
      entities={editions}
      relatedEntities={publishersByUris}
      {itemsByEditions}
    />
  {:else}
    <div class="no-edition-wrapper">
      {I18n('no editions found')}
    </div>
  {/if}
  {#if loggedIn}
    <EditionCreation
      work={parentEntity}
      bind:editions={initialEditions}
    />
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";

  .editions-section{
    @include display-flex(column, center);
    @include radius;
    padding: 0.5em;
    inline-size: 100%;
    background-color: $off-white;
  }
  .editions-list-title{
    @include display-flex(row, center, center);
    margin-block-end: 0.5em;
    h5{
      @include sans-serif;
      margin-block-end: 0;
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
  @media screen and (width >= $small-screen){
    .editions-section{
      padding: 1em;
    }
  }
</style>
