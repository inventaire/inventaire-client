<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import { removeAuthorsClaims } from '#entities/components/lib/work_helpers'
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

  export let entity, standalone, flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`)

  let sections
  const waitingForSubEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'author')
  const authorProperties = Object.keys(extendedAuthorsKeys)
  setContext('search-filter-claim', authorProperties.map(property => `${property}=${uri}`).join('|'))
  setContext('search-filter-types', [ 'series', 'works' ])
  const createButtons = [
    { type: 'serie', claims: { 'wdt:P50': [ uri ] } },
    { type: 'work', claims: { 'wdt:P50': [ uri ] } },
  ]
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <EntityTitle {entity} {standalone}/>
        <div class="infobox-and-summary">
          {#if entity.image}
            <div class="entity-image">
              <EntityImage
                entity={entity}
                size={192}
              />
            </div>
          {/if}
          <Infobox
            claims={removeAuthorsClaims(entity.claims)}
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
      questionText={'A series or a work by this author is missing in the common database?'}
      {createButtons}
    />
    <div class="relatives-lists">
      <RelativeEntitiesList
        {entity}
        property="wdt:P737"
        label={i18n('authors_influenced_by', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property="wdt:P921"
        label={i18n('works_about_entity', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property={[ 'wdt:P2679', 'wdt:P2680' ]}
        label={i18n('editions_prefaced_or_postfaced_by_author', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property="wdt:P655"
        label={i18n('editions_translated_by_author', { name: entity.label })}
      />
    </div>
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#entities/scss/relatives_lists';
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
  .author-works{
    margin-top: 1em;
  }
  .entity-image{
    margin-right: 1em
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .infobox-and-summary{
      @include display-flex(row, flex-start, flex-start);
      :global(.claims-infobox-wrapper), :global(.summary-wrapper){
        width: 50%;
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