<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import autosize from 'autosize'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import { formatCandidatesData } from '#inventory/lib/import_helpers'

  export let createPreCandidates, createCandidatesQueue

  let isbnsText, flash

  const onIsbnsChange = async () => {
    flash = null
    if (!isbnsText || isbnsText.length === 0) return

    const isbnPattern = /(97(8|9))?[\d-]{9,14}([\dX])/g
    const isbns = isbnsText.match(isbnPattern)
    if (isbns === null) return flash = { type: 'error', message: 'no ISBN found' }
    const candidatesData = formatCandidatesData(isbns)
    const invalidIsbns = getInvalidIsbnsString(isbns)
    if (invalidIsbns.length > 0) {
      const message = I18n('invalid_isbns_warning', { invalidIsbns })
      flash = { type: 'warning', message }
    }
    createPreCandidates(candidatesData)
  }

  const getInvalidIsbnsString = isbns => {
    const isbnsData = isbns.map(isbn => {
      const isbnData = isbnExtractor.getIsbnData(isbn)
      if (isbnData.isInvalid) return isbn
    })
    return _.compact(isbnsData).join(', ')
}

  const clearIsbnText = () => {
    // Todo: do not display flash no isbn found
    flash = null
    isbnsText = ''
  }
</script>
<p class="importer-name">
  {I18n('import from a list of ISBNs')}
</p>
<div class="textarea-wrapper">
  <textarea
    bind:value={isbnsText}
    aria-label="{i18n('isbns list')}"
    placeholder="{i18n('paste any kind of text containing ISBNs here')}"
    on:keyup="{onIsbnsChange}"
    use:autosize
  ></textarea>
  <button
    class="grey-button"
    on:click="{clearIsbnText}"
    >
    {I18n('clear text')}
  </button>
</div>
<div class="flash-wrapper">
  <Flash bind:state={flash}/>
</div>
<button
  on:click={createCandidatesQueue}
  class="success-button"
  >
  {I18n('find ISBNs')}
</button>
<style lang="scss">
  @import '#modules/general/scss/utils';
  .importer-name, textarea{
    margin: 0 0.7em;
  }
  .textarea-wrapper{
    @include display-flex(row, flex-start);
  }
  .flash-wrapper{
    margin-top: 1em;
    margin-left: 0.5em;
  }
  .textarea-wrapper,.flash-wrapper{
    margin-right: 0.5em;
  }
  .success-button{
    display: block;
    margin: 0.5em auto;
  }
  .grey-button{
    padding: 0.5em;
  }
</style>
