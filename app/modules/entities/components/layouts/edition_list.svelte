<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { getPublicationDate, getIsbn, formatClaim, formatEntityClaim } from '#entities/components/lib/claims_helpers'
  import EntityImage from '../entity_image.svelte'
  import { loadInteralLink } from '#lib/utils'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'

  export let edition, authorsUris

  const addClaim = prop => {
    const values = edition.claims[prop]
    if (values) {
      return formatClaim({
        prop,
        values,
        omitLabel: true,
        inline: true
      })
    }
  }

  const editionInfoLine = () => {
    const lineElements = [
      getPublicationDate(edition),
      addClaim('wdt:P123'),
      getIsbn(edition),
    ]
    return _.compact(lineElements)
  }

  let lineElements = editionInfoLine()
  const favoriteLabel = getFavoriteLabel(edition)
</script>
<div class="edition-list-info">
  <div>
    <a class='edition-title' href="/entity/{edition.uri}" on:click={loadInteralLink}>
      {favoriteLabel}
    </a>
  </div>
  {#if isNonEmptyArray(authorsUris)}
    <div class="authors-line">
      {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
    </div>
  {/if}
  <div class="edition-info-line">
    {#each lineElements as lineEl}
      <span>
        {@html lineEl}
      </span>
    {/each}
  </div>
</div>
{#if edition.image}
  <div class="cover">
    <EntityImage
      entity={edition}
      withLink={true}
    />
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .edition-title{
    @include link-dark;
  }
  .authors-line{
    font-style: italic;
  }
  .cover{
    max-width: 7em;
    margin-left: 1em;
  }
  .edition-list-info{
    @include display-flex(column, flex-start);
    padding: 0.3em;
    margin-left: 0.5em
  }
  .edition-info-line{
    :not(:last-child):after{
      margin-right: 0.2em;
      content: ',';
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .cover{
      width: 5em
    }
  }
</style>
