<script>
  import BaseLayout from './base_layout.svelte'
  import EntityImage from '../entity_image.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import RelativeEntitiesLists from './relative_entities_lists.svelte'
  import { setContext } from 'svelte'
  import { runEntityNavigate } from '#entities/lib/document_metadata'
  import { isStandaloneEntityType } from '#entities/lib/types/entities_types'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { loadInternalLink } from '#lib/utils'

  export let entity

  const { uri, type } = entity
  let { label } = entity

  runEntityNavigate(entity)

  setContext('layout-context', type)

  const typeLabel = 'subject'

  let flash
</script>

<BaseLayout
  bind:entity
  bind:flash
  {typeLabel}
  showEntityEditButtons={false}
>
  <div class="entity-layout" slot="entity">
    <div class="title-row">
      <a
        href={`/entity/${uri}`}
        on:click={loadInternalLink}
      >
        <h2>
          {label}
        </h2>
      </a>
    </div>
    <div class="top-section">
      {#if !isStandaloneEntityType(type)}
        {#if isNonEmptyPlainObject(entity.image)}
          <EntityImage
            {entity}
            size={192}
          />
        {/if}
        <Summary {entity} />
      {/if}
    </div>
    <div class="relatives-browser">
      <RelativeEntitiesLists {entity}
      />
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
  a:hover{
    text-decoration: underline;
  }
  .top-section{
    @include display-flex(row, center);
    :global(.entity-image){
      flex: 1 0 auto;
      margin-inline-end: 1em;
    }
  }
  .title-row{
    @include display-flex(row, center);
  }
  .relatives-browser{
    margin-block-start: 1em;
  }
  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    .top-section{
      display: block;
      :global(.entity-image){
        margin-block-end: 1em;
      }
    }
  }
</style>
