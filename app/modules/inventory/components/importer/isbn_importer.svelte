<script lang="ts">
  import autosize from 'autosize'
  import { onMount, createEventDispatcher } from 'svelte'
  import { getInvalidIsbnsString } from '#inventory/components/importer/lib/importers_helpers'
  import { formatCandidatesData } from '#inventory/lib/importer/import_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { findIsbns } from '#lib/isbn'
  import { i18n, I18n } from '#user/lib/i18n'

  export let isbns: string[] = null

  const dispatch = createEventDispatcher()

  let isbnsText, flash

  onMount(() => {
    if (isbns) {
      isbnsText = isbns.join('\n')
      checkIsbns()
      findIsbnsAndCreateCandidates()
    }
  })

  function checkIsbns () {
    flash = null
    if (!isbnsText || isbnsText.length === 0) return
    isbns = findIsbns(isbnsText)
    if (isbns === null) return flash = { type: 'error', message: 'no ISBN found' }
  }

  function findIsbnsAndCreateCandidates () {
    isbns = findIsbns(isbnsText)
    const candidatesData = formatCandidatesData(isbns)
    const invalidIsbns = getInvalidIsbnsString(isbns)
    if (invalidIsbns.length > 0) {
      const message = I18n('invalid_isbns_warning', { invalidIsbns })
      flash = { type: 'warning', message }
    }
    dispatch('createExternalEntries', candidatesData)
    dispatch('createCandidatesQueue')
  }

  function clearIsbnText () {
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
    aria-label={i18n('ISBNs list')}
    placeholder={i18n('Enter a list of ISBNs or any text containing ISBNs here')}
    on:keyup={checkIsbns}
    use:autosize
  />
  <button
    class="grey-button"
    on:click={clearIsbnText}
  >
    {I18n('clear text')}
  </button>
</div>
<div class="flash-wrapper">
  <Flash bind:state={flash} />
</div>
<button
  on:click={findIsbnsAndCreateCandidates}
  class="success-button"
>
  {I18n('find ISBNs')}
</button>
<style lang="scss">
  @import "#modules/general/scss/utils";
  .importer-name, textarea{
    margin: 0 0.7em;
  }
  .textarea-wrapper{
    @include display-flex(row, flex-start);
  }
  .flash-wrapper{
    margin-block-start: 1em;
    margin-inline-start: 0.5em;
  }
  .textarea-wrapper,.flash-wrapper{
    margin-inline-end: 0.5em;
  }
  .success-button{
    display: block;
    margin: 0.5em auto;
  }
  .grey-button{
    padding: 0.5em;
  }
</style>
