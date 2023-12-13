<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import EntityTitle from './entity_title.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionActions from './edition_actions.svelte'
  import OtherEditions from './other_editions.svelte'
  import { addWorksClaims } from '#entities/components/lib/edition_layout_helpers'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { tick } from 'svelte'
  import { runEntityNavigate } from '#entities/lib/document_metadata'
  import { scrollToElement } from '#lib/screen'

  export let entity, works, standalone

  let showMap, itemsListsWrapperEl, mapWrapperEl

  const { uri, image, label } = entity
  let { claims } = entity

  async function showMapAndScrollToMap () {
    showMap = true
    await tick()
    scrollToElement(mapWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  $: runEntityNavigate(entity)
  $: claims = addWorksClaims(claims, works)
</script>
<BaseLayout {entity}>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      {#if image.url}
        <div class="cover">
          <img src={imgSrc(image.url, 300)} alt={label} loading="lazy" />
        </div>
      {/if}
      <div class="info-wrapper">
        <EntityTitle {entity} {standalone} />
        <div class="infobox-wrapper">
          <div class="author-and-info">
            <AuthorsInfo {claims} />
            <Infobox
              {claims}
              entityType={entity.type}
            />
            <Summary {entity} />
          </div>
          <EditionActions {entity}
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
      <h5 class="other-editions-title">
        {I18n('other editions')}
      </h5>
      <ul class="other-works-editions">
        {#each works as work (work.uri)}
          <OtherEditions
            currentEdition={entity}
            {work}
          />
        {/each}
      </ul>
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    inline-size: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, space-between);
    margin-block-end: 1em;
  }
  .cover{
    padding-inline-end: 1em;
    max-inline-size: 12em;
  }
  .info-wrapper{
    flex: 1;
  }
  .infobox-wrapper{
    @include display-flex(row, center, space-between);
    :global(.summary){
      margin-block-start: 1em;
    }
  }
  .author-and-info{
    margin-inline-end: 1em;
  }
  .items-lists-wrapper{
    margin: 1em 0;
  }
  .bottom-section{
    @include display-flex(column, center);
  }
  .other-editions-title{
    @include sans-serif;
  }
  .other-works-editions{
    @include display-flex(row, initial, space-around, wrap);
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .top-section{
      margin: 0 5em;
    }
  }
  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    .info-wrapper{
      @include display-flex(column, center, center);
      margin-block-start: 1em;
    }
    .infobox-wrapper{
      @include display-flex(column, flex-start, center);
    }
    .top-section{
      @include display-flex(column, center);
    }
  }
  /* Very small screens */
  @media screen and (max-width: $very-small-screen){
    .author-and-info{
      margin-inline-end: 0;
    }
  }
</style>
