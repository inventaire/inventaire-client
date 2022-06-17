<script>
  import { editionShortlist, editionLonglist, removeFromList } from '#entities/components/lib/claims_helpers'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import EntityImage from '../entity_image.svelte'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import EditionActions from './edition_actions.svelte'
  import Infobox from './infobox.svelte'
  import Link from '#lib/components/link.svelte'

  export let entity, relatedEntities, compactView

  const editionLabel = getFavoriteLabel(entity)

  let workEditionLonglist = editionLonglist
  removeFromList(workEditionLonglist, 'wdt:P629')
  removeFromList(workEditionLonglist, 'wdt:P1476')
</script>
<div
  class="edition-list"
  class:compactView
>
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
  {#if !compactView}
    <div class="edition-list-info">
      <div class="edition-info-line">
        <div class="edition-title">
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
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .edition-list{
    @include display-flex(row, flex-start, flex-start);
    border-top: 1px solid #ddd;
    padding: 0.3em 0;
    margin-top: 1em;
  }
  .compactView{
    @include display-flex(row);
    max-width: 5em;
    border-top: none;
    padding: 0;
    margin: 0;
    .cover{
      width: auto;
    }
  }
  .edition-title{
    font-size:larger;
  }
  .cover{
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
