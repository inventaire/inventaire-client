<script>
  import { onMount } from 'svelte'
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import preq from '#lib/preq'

  export let candidate

  let checked = true
  let editionLang
  let { preCandidate, edition, work, authors } = candidate
  const { isbnData } = preCandidate
  const rawIsbn = isbnData?.rawIsbn
  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }
  let entities = {}

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  const getEntitiesFromIsbn = async () => {
    if (!isbnData) return
    const relatives = [ 'wdt:P629', 'wdt:P50' ]
    const uri = `isbn:${isbnData?.normalizedIsbn}`
    const res = await preq.get(app.API.entities.getByUris(uri, false, relatives))
    entities = res.entities
    assignWorkAndAuthors(entities)
  }

  onMount(async () => {
    // spare fetching isbn related entities systematically at creation
    // when candidate already have some relevant data to display
    if (work) return
    await getEntitiesFromIsbn()
  })

  const assignWorkAndAuthors = entities => {
    const entityWork = _.find(entities, entity => entity.type === 'work')
    if (!entityWork) return
    work = entityWork
    if (authors?.length > 0) return
    const workAuthorsUris = work.claims['wdt:P50']
    const workAuthors = _.values(_.pick(entities, workAuthorsUris))
    if (workAuthors.length > 0) authors = workAuthors
  }
</script>
<li class="candidateRow" class:checked="{checked}">
  <div class="column works">
    <div class="column work">
      <div class="column workTitle">
        {#if work}
          {findBestLang(work)}
          <sup class="sourceLogo">
            {#if work.uri?.startsWith('wd:Q')}
              {@html icon('wikidata')}
            {:else if work.uri?.startsWith('inv:')}
              inv
            {/if}
          </sup>
        {/if}
      </div>
      <div class="authors">
        {#if authors}
          {#each authors as author}
            <div class="author">
              {findBestLang(author)}
              {#if author.uri?.startsWith('wd:Q')}
                <sup class="sourceLogo">{@html icon('wikidata')}</sup>
              {:else if author.uri?.startsWith('inv:')}
                <sup class="sourceLogo">inv</sup>
              {/if}
            </div>
          {/each}
        {/if}
      </div>
    </div>
  </div>
  <div class="column isbn">
    {#if rawIsbn}
      {rawIsbn}
    {/if}
  </div>
  <div class="column checkbox">
    <input type="checkbox" bind:checked="{checked}" name="{I18n('select_book')} {rawIsbn}">
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
    .checkbox{
      flex: 1 0 0;
    }
    .isbn{
      flex: 4 0 0;
    }
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .work{
    @include display-flex(row, center, center);
  }
  .authors{
    @include display-flex(column, center, center);
  }
  .isbn{
    @include display-flex(column, baseline, center);
  }
  .author{
    min-height: 2.5em;
    @include display-flex(row, center, center);
  }
  .sourceLogo{
    font-family: "Alegreya", serif;
    font-weight: normal;
    font-style: normal;
    color: #222222;
    padding: 0.15em;
    margin: 0.2em;
  }
  button{
    color:  white;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .column{
      @include display-flex(column, center, center);
    }
    sup{
      display: none
    }
  }
</style>
