<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import preq from '#lib/preq'
  import Spinner from '#components/spinner.svelte'
  export let candidate
  export let checked = true

  let editionLang, disabled
  let { preCandidate, edition, work, authors } = candidate
  const { isbnData } = preCandidate
  const rawIsbn = isbnData?.rawIsbn
  let needInfo, existingItemsCount, existingItemsPathname
  let entities = {}

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  onMount(() => {
    existingItemsCount = preCandidate.existingItemsCount
    if (existingItemsCount && existingItemsCount > 0) {
      const uri = preCandidateUri(preCandidate)
      const username = app.user.get('username')
      existingItemsPathname = `/inventory/${username}/${uri}`
    } else if (!candidate.works || candidate.works.length === 0) {
      needInfo = true
      disabled = true
    }
  })

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  const getEntitiesFromIsbn = async () => {
    if (!isbnData || isbnData.isInvalid) return
    const relatives = [ 'wdt:P629', 'wdt:P50' ]
    const uri = `isbn:${isbnData.normalizedIsbn}`
    const res = await preq.get(app.API.entities.getByUris(uri, false, relatives))
    entities = res.entities
    assignWorkAndAuthors(entities)
  }

  const assignWorkAndAuthors = entities => {
    const entityWork = _.find(entities, entity => entity.type === 'work')
    if (!entityWork) return
    work = entityWork
    if (authors?.length > 0) return
    const workAuthorsUris = work.claims['wdt:P50']
    const workAuthors = _.values(_.pick(entities, workAuthorsUris))
    if (workAuthors.length > 0) authors = workAuthors
  }

  $: if (isbnData?.isInvalid) disabled = true
  $: if (disabled && checked) checked = false
  $: candidate.checked = checked
</script>
<li class="candidateRow" class:checked>
  <div class="data">
    {#if work}
      <div class="column workTitle">
        <span class="label">{i18n('title')}:</span>
        {findBestLang(work)}
        {#if work.uri?.startsWith('wd:Q')}
          <sup class="supLogo">{@html icon('wikidata')}</sup>
        {:else if work.uri?.startsWith('inv:')}
          <sup class="supLogo">inv</sup>
        {/if}
      </div>
    {:else}
      <div class="column workTitle">
        {#await getEntitiesFromIsbn()}
          <Spinner/>
        {/await}
      </div>
    {/if}
    {#if authors}
      <span class="column authors">
        <span class="label">{i18n('authors')}:</span>
        {#each authors as author, id}
          <span class="author">
            {findBestLang(author)}
          </span>
          {#if author.uri?.startsWith('wd:Q')}
            <sup class="supLogo">{@html icon('wikidata')}</sup>
          {:else if author.uri?.startsWith('inv:')}
            <sup class="supLogo">inv</sup>
          {/if}
          {#if id !== authors.length - 1},&nbsp;{/if}
        {/each}
      </span>
    {/if}
    <div class="column isbn">
      {#if rawIsbn}
        {#if isbnData?.isInvalid}
          <span class="warning">{i18n('invalid ISBN')}</span>
        {:else}
          <span class="label">ISBN:</span>
        {/if}
        {rawIsbn}
      {/if}
    </div>
    <div class="column status">
      {#if needInfo}
        <div>{i18n('need more information')}</div>
      {/if}
      {#if existingItemsCount}
        <span class="existing-entity-items">
          {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
        </span>
      {/if}
    </div>
  </div>
  <div class="checkbox">
    <input type="checkbox" bind:checked {disabled} name="{I18n('select_book')} {rawIsbn}">
  </div>
</li>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .column{
    flex: 20 0 0;
    padding: 0.2em;
  }
  .candidateRow{
    @include display-flex(row, center, center);
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .data{
    @include display-flex(row, center, flex-start);
    flex: 1 0 0;
    .isbn{
      @include display-flex(column);
      text-align: right;
      flex: 5 0 0;
    }
    .supLogo{
      font-family: "Alegreya", serif;
      font-weight: normal;
      font-style: normal;
      color: #222222;
    }
    .hidden, .label{
      display: none;
    }
  }

  .checkbox{
    padding-left: 1em;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .warning{
    background-color: lighten($yellow, 30%);
    color: darken($success-color, 70%);
    padding: 0.3em;
  }

  /*Small screens*/
  @media screen and (max-width: 45em) {
    .data{
      @include display-flex(column);
      .column{
        text-align: left;
      }
      .isbn{
        @include display-flex(row, center);
      }
      .warning{
        margin-right: 0.5em;
      }
      .label{
        display: inline;
        color: $grey;
        margin-right: 0.5em;
      }
    }
  }
</style>
