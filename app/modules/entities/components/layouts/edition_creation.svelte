<script>
  import { i18n } from '#user/lib/i18n'
  import wdLang from 'wikidata-lang'
  import { looksLikeAnIsbn, normalizeIsbn } from '#lib/isbn'
  import { isNonEmptyString } from '#lib/boolean_tests'
  import { getEntityPropValue } from '#entities/components/lib/claims_helpers'
  import { buildPath } from '#lib/location'
  import { createEditionFromWork } from '#entities/components/lib/create_edition_from_work.js'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import '#entities/scss/edition_creation.scss'
  import { icon } from '#lib/utils'
  import Link from '#lib/components/link.svelte'
  import Flash from '#lib/components/flash.svelte'
  import error_ from '#lib/error'

  export let work, editions

  let userInput = ''
  let flash
  let showForm

  const isbnButton = async () => {
    flash = null
    const flashErrMessage = validateEditionPossibility(userInput)
    if (isNonEmptyString(flashErrMessage)) {
      flash = {
        type: 'error',
        message: flashErrMessage
      }
      throw error_.new(flashErrMessage)
    }
    await createEditionFromWork({
      workEntity: work,
      userInput,
    })
    .catch(err => {
      err.escapeHtml = true
      flash = err
    })
    .then(newEdition => {
      editions = [ newEdition, ...editions ]
    })
  }

  const getNormalizedIsbn = edition => {
    const isbn = getEntityPropValue(edition, 'wdt:P212')
    if (isbn) return normalizeIsbn(isbn)
  }

  const validateEditionPossibility = userInput => {
    if (!looksLikeAnIsbn(userInput)) return 'invalid isbn'
    const isbn = normalizeIsbn(userInput)
    if (editions.map(getNormalizedIsbn).includes(isbn)) {
      return 'this edition is already in the list'
    }
  }

  const addWithoutIsbnPath = function () {
    if (!work) return {}
    return buildPath('/entity/new', workEditionCreationData(work))
  }

  const workEditionCreationData = function () {
    const data = {
      type: 'edition',
      claims: {
        'wdt:P629': [ work.uri ]
      }
    }
    const { lang } = app.user
    const langWdId = wdLang.byCode[lang]?.wd
    const langWdUri = (langWdId != null) ? `wd:${langWdId}` : undefined
    // Suggest user's language as edition language
    if (langWdUri) data.claims['wdt:P407'] = [ langWdUri ]

    const favoriteLabel = getFavoriteLabel(work)
    // Suggest work label in user's language as edition title
    if (favoriteLabel) data.claims['wdt:P1476'] = [ favoriteLabel ]

    return data
  }
</script>
<div class="wrapper">
<div class="edition-creation-svelte">
  {#if showForm}
    <div class="from-isbn">
      <label for="isbnGroup">
      	{i18n('Add an edition by its ISBN')}
      </label>
      <form id="isbnGroup" class="inputGroup">
        <div class="inputBox">
          <input type="text"
            id="isbnField"
            name="isbn"
            class="has-alertbox enterClick"
            bind:value={userInput}
            placeholder="ex: 2070368228"
            aria-label="isbn"
          >
        </div>
        <button
          id="isbnButton"
          class="button grey postfix sans-serif"
          on:click={isbnButton}
        >
          {@html icon('plus')}
          {i18n('add')}
        </button>
      </form>
    </div>
    <button id="withoutIsbn" class="tiny-button grey">
      <Link
        url={addWithoutIsbnPath()}
        text={'add an edition without an ISBN'}
        icon='plus'
        light={true}
      />
    </button>
  {:else}
    <button
      class="tiny-button show-form"
      on:click={() => showForm = true}
    >
      {@html icon('plus')}
      {i18n('add missing edition')}
    </button>
  {/if}

  <Flash bind:state={flash}/>
</div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .edition-creation-svelte{
    @include display-flex(row, flex-start, flex-start, wrap);
    @include radius;
    margin: 1em;
    flex-direction: column;
    align-items: stretch;
    max-width:20em;
  }
  .wrapper{
    @include display-flex(row, center, center);
  }
  #isbnButton{
    @include display-flex(row, center, center);
    white-space: nowrap;
    // avoid .postfix to put button above langauge dropdown menu
    z-index:0
  }
  #withoutIsbn{
    @include display-flex(row, center, center);
    font-size: 0.9em;
    padding: 0.5em;
  }
  .show-form{
    padding: 0.3em;
    max-width:20em;
    font-size: 0.9em;
  }
</style>
