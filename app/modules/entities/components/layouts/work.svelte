<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import { getWorkProperties } from '#entities/components/lib/claims_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import WikipediaExtract from './wikipedia_extract.svelte'
  import ItemsLists from './items_lists.svelte'

  export let entity, standalone, mapToShow

  const omitAuthorsProperties = true
  const { uri } = entity
  let editionsUris
  let initialEditions = []

  const workShortlist = [
    'wdt:P577',
    'wdt:P136',
    'wdt:P921',
  ]

  const getEditions = async () => {
    initialEditions = await getSubEntities('work', uri)
    editions = initialEditions
  }

  let editions = getEditions()

  $: claims = entity.claims
  $: notOnlyP31 = Object.keys(claims).length > 1
  $: app.navigate(`/entity/${uri}`)
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = editions && isNonEmptyArray(editions)
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      {#if notOnlyP31}
        <div class="work-section">
          <AuthorsInfo
            {claims}
          />
          <Infobox
            {claims}
            propertiesLonglist={getWorkProperties(omitAuthorsProperties)}
            propertiesShortlist={workShortlist}
          />
          <WikipediaExtract
            {entity}
          />
        </div>
      {/if}
    </div>
    {#await editions}
      <div class="loading-wrapper">
        <p class="loading">{I18n('looking for editions...')}
          <Spinner/>
        </p>
      </div>
    {:then}
      {#if someEditions}
        <div
          class="editions-list"
        >
          <!-- TODO: dont display items list if items owners are only main user items -->
          <ItemsLists
            {editionsUris}
            bind:mapToShow={mapToShow}
          />
        </div>
      {/if}
    {/await}
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    width: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
  }
  .editions-list{
    @include display-flex(column, center);
    margin: 1em 0;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .work-section{
      margin-left: 0;
      margin-right: 1em;
    }
  }

  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .top-section{
      @include display-flex(column);
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
