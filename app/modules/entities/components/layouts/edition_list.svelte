<script>
  import { i18n } from '#user/lib/i18n'
  import { getPublicationDate, getIsbn } from '#entities/components/lib/claims_helpers'
  import EntityImage from '../entity_image.svelte'
  import { loadInteralLink } from '#lib/utils'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import EntityValueInline from './entity_value_inline.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'

  export let edition, publishersByUris = {}

  const findEditionPublisher = edition => {
    const publisherUris = edition?.claims['wdt:P123']
    if (!publisherUris || !publisherUris[0]) return
    return publishersByUris[publisherUris[0]]
  }

  const publisher = findEditionPublisher(edition)
  let publisherLabel, publisherUri
  if (publisher) {
    publisherLabel = getBestLangValue(app.user.lang, null, publisher.labels).value
    publisherUri = publisher.uri
  }

  const editionLabel = getFavoriteLabel(edition)
  const isbn = getIsbn(edition)
  const { publicationYear } = getPublicationDate(edition)
</script>
<div class="edition-list-info">
  <div>
    <a class='edition-title' href="/entity/{edition.uri}" on:click={loadInteralLink}>
      {editionLabel}
    </a>
  </div>
  <div class="edition-info-line">
    {#if publisherUri}
      <div class="publisher">
        <EntityValueInline
          uri={publisherUri}
          label={publisherLabel}
          title={publisherLabel}
        />
      </div>
    {/if}
    {#if publicationYear}
      <div class="publication-year">
        <span class='text-help'>
          {i18n('published')}
        </span>
        {publicationYear}
      </div>
    {/if}
    {#if isbn}
      <div class="isbn">
        {isbn}
      </div>
    {/if}
  </div>
</div>
{#if edition.image}
  <div class="cover">
    <EntityImage
      entity={edition}
      withLink={true}
      maxHeight={'4em'}
    />
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .edition-title{
    @include link-dark;
  }
  .cover{
    max-width: 7em;
    margin-left: 1em;
  }
  .edition-list-info{
    @include display-flex(column, flex-start, flex-start);
    padding: 0.3em;
    margin-left: 0.5em
  }
  .edition-info-line{
    @include display-flex(row, center, flex-start, wrap);
    :not(:last-child):after{
      margin-right: 0.2em;
      content: ',';
    }
  }
  .text-help{
    color: $grey;
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .cover{
      width: 5em
    }
  }
</style>
