<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { isOpenedOutside } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getTitle, getPublicationDate, formatClaim, formatEntityClaim } from '#entities/components/lib/claims_helpers'

  export let edition, authorsUris, itemsByEdition

  let editionItemsCount

  const { id } = edition

  const url = `/entity/${id}`

  const showEdition = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      // TODO: on item modal close, it should navigate back to entity page
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }

  const addClaim = prop => {
    const values = edition.claims[prop]
    if (values) return formatClaim({ prop, values, omitLabel: true })
  }

  $: {
    if (itemsByEdition && itemsByEdition[edition.uri]) {
      let editionItems = itemsByEdition[edition.uri]
      if (editionItems) editionItemsCount = editionItems.length
    }
  }
</script>
<div class="edition-list">
  <a
    href="{url}"
    on:click={showEdition}
  >
    <div class="cover">
      <img src="{imgSrc(edition.image.url, 128)}" alt="{i18n(getTitle(edition))}">
    </div>
  </a>
  <div class="edition-list-info">
    <div>
      {getTitle(edition)}
    </div>
    {#if isNonEmptyArray(authorsUris)}
      <div class="authors-line">
        {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
      </div>
    {/if}
    <div class="edition-info-line">
      {#if getPublicationDate(edition)}
        {getPublicationDate(edition)} -
      {/if}
      {@html addClaim('wdt:P123')}
    </div>
    {#if itemsByEdition}
      <a
        href="{url}"
        on:click={showEdition}
      >
        {i18n('books found', { book_count: editionItemsCount })}
      </a>
    {/if}
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .edition-list{
    @include display-flex(row, center,flex-start,wrap);
    background-color: $off-white;
    border-bottom: 1px solid #ddd;
    padding: 0.5em;
  }
  .cover{
    max-width: 5em;
  }
  .edition-list-info{
    @include display-flex(column, flex-start);
    padding: 1em;
  }
</style>
