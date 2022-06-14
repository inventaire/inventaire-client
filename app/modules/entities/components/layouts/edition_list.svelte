<script>
  import { editionShortlist, editionLonglist, removeFromList } from '#entities/components/lib/claims_helpers'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import EntityImage from '../entity_image.svelte'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import EditionActions from './edition_actions.svelte'
  import Infobox from './infobox.svelte'
  import Link from '#lib/components/link.svelte'

  export let entity, relatedEntities = {}

  const editionLabel = getFavoriteLabel(entity)

  let workEditionLonglist = editionLonglist
  removeFromList(workEditionLonglist, 'wdt:P629')
  removeFromList(workEditionLonglist, 'wdt:P1476')
</script>
<div class="edition-list">
  {#if isNonEmptyPlainObject(entity.image)}
    <div class="cover">
      <EntityImage
        {entity}
        withLink={true}
        maxHeight={'6em'}
        size={128}
      />
    </div>
  {/if}
  <div class="edition-list-info">
    <div class="edition-info-line">
      <div>
        <Link
          url={`/entity/${entity.uri}`}
          text={editionLabel}
          dark={true}
        />
      </div>
      <div class="edition-details">
        <Infobox
          claims={entity.claims}
          propertiesLonglist={workEditionLonglist}
          propertiesShortlist={editionShortlist}
          {relatedEntities}
          compactView={true}
        />
      </div>
    </div>
    <div class="edition-actions">
      <EditionActions {entity}/>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .edition-list{
    @include display-flex(row, flex-start, flex-start);
  }
  .edition-title{
    font-size:larger;
  }
  .cover{
    min-width: 5em;
    margin-right: 0.5em;
    margin-top: 0.5em;
  }
  .edition-list-info{
    @include display-flex(row, center, space-between);
    margin-left: 0.5em;
  }
  .edition-info-line{
    margin-right: 0.5em;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .cover{
      width: 5em
    }
  }

  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .edition-list-info{
      @include display-flex(column);
    }
  }
</style>
