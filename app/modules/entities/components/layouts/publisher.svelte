<script lang="ts">
  import { setContext } from 'svelte'
  import ActorFollowersSection from '#entities/components/layouts/actor_followers_section.svelte'
  import AddToDotDotDotMenu from '#entities/components/layouts/add_to_dot_dot_dot_menu.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import { runEntityNavigate } from '#entities/lib/document_metadata'
  import Spinner from '#general/components/spinner.svelte'
  import EntityListingsLayout from '#listings/components/entity_listings_layout.svelte'
  import BaseLayout from './base_layout.svelte'
  import HomonymDeduplicates from './deduplicate_homonyms.svelte'
  import EntityTitle from './entity_title.svelte'
  import Infobox from './infobox.svelte'

  export let entity
  let flash

  const { uri } = entity
  runEntityNavigate(entity)

  let sections
  // server is already sorting byPublicationDate
  const waitingForSubEntities = getSubEntitiesSections({ entity })
    .then(res => sections = res)
    .catch(err => flash = err)

  // TODO: index editions
  // setContext('search-filter-types', null)
  setContext('layout-context', 'publisher')
  setContext('search-filter-claim', `wdt:P123=${uri}`)
</script>

<BaseLayout
  bind:entity
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div>
        <EntityTitle {entity} />
        <Infobox
          claims={entity.claims}
          entityType={entity.type}
        />
        <Summary {entity} />
        <AddToDotDotDotMenu
          {entity}
          {flash}
          align="left"
        />
      </div>
      {#await waitingForSubEntities}
        <Spinner center={true} />
      {:then}
        <div class="publications">
          <WorksBrowser {sections} />
        </div>
        <!-- Nest listings within WorksBrowser section to load it at the same time,
        to not have to push it down when WorksBrowser is displayed -->
        <EntityListingsLayout {entity} />
      {/await}
    </div>
    <ActorFollowersSection uri={entity.uri} />
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
    :global(.summary.has-summary){
      margin-block-start: 1em;
    }
  }
  .publications{
    margin-block-start: 1em;
  }
  .top-section{
    :global(.add-to-dot-dot-dot-menu){
      margin-block-start: 1em;
      width: 10em;
    }
  }
</style>
