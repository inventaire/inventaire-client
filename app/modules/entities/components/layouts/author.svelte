<script lang="ts">
  import { setContext } from 'svelte'
  import { debounce } from 'underscore'
  import { isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import { onChange } from '#app/lib/svelte/svelte'
  import ActorFollowersSection from '#entities/components/layouts/actor_followers_section.svelte'
  import AddToDotDotDotMenu from '#entities/components/layouts/add_to_dot_dot_dot_menu.svelte'
  import RelativeEntitiesList from '#entities/components/layouts/relative_entities_list.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import { getRelativeEntitiesListLabel, getRelativeEntitiesProperties } from '#entities/components/lib/relative_entities_helpers'
  import { runEntityNavigate } from '#entities/lib/document_metadata'
  import { extendedAuthorsKeys } from '#entities/lib/types/author_alt'
  import Spinner from '#general/components/spinner.svelte'
  import EntityListingsLayout from '#listings/components/entity_listings_layout.svelte'
  import EntityImage from '../entity_image.svelte'
  import BaseLayout from './base_layout.svelte'
  import HomonymDeduplicates from './deduplicate_homonyms.svelte'
  import EntityTitle from './entity_title.svelte'
  import Infobox from './infobox.svelte'

  export let entity
  let flash

  const { uri, type, claims } = entity
  runEntityNavigate(entity)

  setContext('layout-context', 'author')
  const authorProperties = Object.keys(extendedAuthorsKeys)

  setContext('search-filter-claim', authorProperties.map(property => `${property}=${uri}`).join('|'))
  setContext('search-filter-types', [ 'series', 'works' ])

  let sections, waitingForSubEntities
  function getSections () {
    waitingForSubEntities = getSubEntitiesSections({ entity })
      .then(res => sections = res)
      .catch(err => flash = err)
  }

  const lazyGetSections = debounce(getSections, 100)
  $: if (entity) onChange(entity, lazyGetSections)
</script>

<BaseLayout
  bind:entity
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div>
        <EntityTitle {entity} />
        <div class="info-section">
          {#if isNonEmptyPlainObject(entity.image)}
            <EntityImage
              {entity}
              size={192}
            />
          {/if}
          <Infobox
            {claims}
            entityType={entity.type}
          />
          <div class="right-section">
            <Summary {entity} />
            <AddToDotDotDotMenu
              {entity}
              {flash}
              align="right"
            />
          </div>
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
    <!-- waiting for subentities to not display relative entities list before work browser -->
    <!-- to not having to push them down while work browser is being displayed -->
    {#await waitingForSubEntities then}
      <div class="relatives-lists">
        {#each getRelativeEntitiesProperties(type) as property}
          <RelativeEntitiesList
            {entity}
            {property}
            label={getRelativeEntitiesListLabel({ property, entity })}
          />
        {/each}
      </div>
      <div class="entity-listings-layout">
        <EntityListingsLayout {entity} />
      </div>
      <ActorFollowersSection uri={entity.uri} />
      <HomonymDeduplicates {entity} />
    {/await}
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/relatives_lists";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
    :global(.summary.has-summary){
      margin-block-start: 1em;
    }
  }
  .entity-listings-layout{
    margin: 1em 0;
  }
  .author-works{
    margin-block-start: 1em;
  }
  .info-section{
    :global(.entity-image){
      margin-inline-end: 1em;
    }
  }
  .right-section{
    @include display-flex(column, flex-end);
    :global(.add-to-dot-dot-dot-menu){
      margin-block-start: 1em;
      width: 10em;
    }
  }
  .relatives-lists{
    @include relatives-lists-commons;
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .info-section{
      @include display-flex(row, flex-start, flex-start);
      :global(.claims-infobox-wrapper), .right-section{
        inline-size: 50%;
      }
      :global(.claims-infobox){
        margin-inline-end: 1em;
        margin-block-end: 1em;
      }
      :global(.summary.has-summary){
        margin-block-start: 0;
      }
    }
  }
</style>
