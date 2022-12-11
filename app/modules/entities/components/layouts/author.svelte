<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { authorsProps, relativeEntitiesListsProps } from '#entities/components/lib/claims_helpers'
  import { inverseLabels } from '#entities/components/lib/claims_helpers'
  import BaseLayout from './base_layout.svelte'
  import Infobox from './infobox.svelte'
  import EntityTitle from './entity_title.svelte'
  import EntityImage from '../entity_image.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { extendedAuthorsKeys } from '#entities/lib/show_all_authors_preview_lists'
  import MissingEntitiesMenu from '#entities/components/layouts/missing_entities_menu.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import RelativeEntitiesList from '#entities/components/layouts/relative_entities_list.svelte'
  import { i18n } from '#user/lib/i18n'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { getEntityMetadata } from '#entities/lib/document_metadata'

  export let entity, standalone
  let flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })

  let sections
  const waitingForSubEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'author')
  const authorProperties = Object.keys(extendedAuthorsKeys)
  let relativeEntitiesProperties = [ 'wdt:P737', 'wdt:P921', 'wdt:P855' ]

  setContext('search-filter-claim', authorProperties.map(property => `${property}=${uri}`).join('|'))
  setContext('search-filter-types', [ 'series', 'works' ])
  const createButtons = [
    { type: 'serie', claims: { 'wdt:P50': [ uri ] } },
    { type: 'work', claims: { 'wdt:P50': [ uri ] } },
  ]
</script>

<BaseLayout
  bind:entity
  {standalone}
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <EntityTitle {entity} {standalone} />
        <div class="infobox-and-summary">
          {#if isNonEmptyPlainObject(entity.image)}
            <EntityImage
              {entity}
              size={192}
            />
          {/if}
          <Infobox
            claims={omitClaims(entity.claims, [ authorsProps, relativeEntitiesListsProps ])}
            entityType={entity.type}
          />
          <Summary {entity} />
        </div>
      </div>
      <div class="author-works">
        {#await waitingForSubEntities}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
    </div>
    <MissingEntitiesMenu
      waiting={waitingForSubEntities}
      questionText="A series or a work by this author is missing in the common database?"
      {createButtons}
    />
    <div class="relatives-lists">
      <RelativeEntitiesList
        {entity}
        claims={entity.claims['wdt:P737']}
        label={i18n('authors_or_works_influencing_author', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property={[ 'wdt:P2679', 'wdt:P2680' ]}
        label={i18n('editions_prefaced_or_postfaced_by_author', { name: entity.label })}
      />
      {#each relativeEntitiesProperties as property}
        <RelativeEntitiesList
          {entity}
          {property}
          label={i18n(inverseLabels[property], { name: entity.label })}
        />
      {/each}
    </div>
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/relatives_lists";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
  .author-works{
    margin-top: 1em;
  }
  .infobox-and-summary{
    :global(.entity-image){
      margin-right: 1em;
      max-width: 9em;
    }
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .infobox-and-summary{
      @include display-flex(row, flex-start, flex-start);
      :global(.claims-infobox-wrapper), :global(.summary){
        width: 50%;
      }
      :global(.claims-infobox){
        margin-right: 1em;
        margin-bottom: 1em;
      }
    }
    .relatives-lists{
      @include display-flex(row, baseline, flex-start, wrap);
      $margin: 1rem;
      // Hide the extra margin on each wrapped line
      margin-inline-end: -$margin;
      :global(.relative-entities-list.not-empty){
        flex: 1 0 40%;
        margin-inline-end: $margin;
        margin-bottom: $margin;
      }
    }
  }
</style>
