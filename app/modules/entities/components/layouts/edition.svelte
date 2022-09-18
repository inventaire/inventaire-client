<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import EntityTitle from './entity_title.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionActions from './edition_actions.svelte'
  import OtherEditions from './other_editions.svelte'
  import { addWorksClaims, filterClaims } from '#entities/components/lib/edition_layout_helpers'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { tick } from 'svelte'
  import screen_ from '#lib/screen'
  import { getEntityMetadata } from '#entities/lib/document_metadata'

  export let entity, works, standalone

  let showMap, itemsListsWrapperEl, mapWrapperEl

  const { uri, image, label } = entity
  let { claims } = entity

  const claimsWithWorksClaims = _.pick(claims, filterClaims)

  const firstWorkUri = works[0].uri

  async function showMapAndScrollToMap () {
    showMap = true
    await tick()
    screen_.scrollToElement(mapWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  $: app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })
  $: claims = addWorksClaims(claimsWithWorksClaims, works)
</script>
<BaseLayout
  {entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      {#if image.url}
        <div class="cover">
          <img src={imgSrc(image.url, 300)} alt={label}>
        </div>
      {/if}
      <div class="info-wrapper">
        <EntityTitle {entity} {standalone}/>
        <div class="infobox-wrapper">
          <div class="infobox">
            <AuthorsInfo
              {claims}
            />
            <Infobox
              {claims}
              entityType={entity.type}
            />
            <Summary {entity} />
          </div>
          <EditionActions
            {entity}
          />
        </div>
      </div>
    </div>
    <div class="items-lists-wrapper">
      <ItemsLists
        editionsUris={[ uri ]}
        bind:showMap
        bind:mapWrapperEl
        bind:itemsListsWrapperEl
        on:showMapAndScrollToMap={showMapAndScrollToMap}
      />
    </div>
    <div class="bottom-section">
      <OtherEditions
        currentEdition={entity}
        workUri={firstWorkUri}
      />
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-layout{
    width: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, space-between);
    margin-bottom: 1em;
  }
  .cover{
    padding-right: 1em;
    max-width: 12em;
  }
  .infobox-wrapper{
    @include display-flex(row, center, space-between);
    :global(.summary-wrapper){
      margin-top: 1em;
    }
  }
  .info-wrapper{
    flex: 1;
  }
  .infobox{
    margin-bottom: 1em;
  }
  .items-lists-wrapper{
    margin: 1em 0
  }
  .bottom-section{
    @include display-flex(column, center);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .top-section{
      margin:0 5em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .infobox-wrapper{
      @include display-flex(column, flex-start, center);
    }
  }
  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .infobox{
      width:100%;
    }
    .info-wrapper{
      @include display-flex(column, center, center);
    }
    .top-section{
      margin: 0 2em;
      @include display-flex(column, center);
    }
  }
</style>
