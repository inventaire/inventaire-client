<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import { aggregateWorksClaims, infoboxPropsLists } from '#entities/components/lib/claims_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import OtherEditions from './other_editions.svelte'
  import EntityTitle from './entity_title.svelte'
  import EditionActions from './edition_actions.svelte'

  export let entity, works, standalone

  const { uri, image } = entity
  let { claims } = entity

  const addWorksClaims = (claims, works) => {
    const worksClaims = aggregateWorksClaims(works)
    const nonEmptyWorksClaims = _.pick(worksClaims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyWorksClaims)
  }

  const filterClaims = (_, key) => infoboxPropsLists.edition.long.includes(key)

  const claimsWithWorksClaims = _.pick(claims, filterClaims)

  const label = getFavoriteLabel(entity)

  const firstWorkUri = works[0].uri

  $: app.navigate(`/entity/${uri}`)
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
          </div>
          <EditionActions
            {entity}
          />
        </div>
      </div>
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
    @include display-flex(row, center, space-between);
    margin-bottom: 1em;
  }
  .infobox{
    margin-bottom: 1em;
  }
  .infobox-wrapper{
    @include display-flex(row, center, space-between);
  }
  .info-wrapper{
    flex: 1;
  }
  .cover{
    padding-right: 1em;
    max-width: 12em;
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
