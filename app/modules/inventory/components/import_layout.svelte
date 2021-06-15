<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from 'modules/user/lib/i18n'
  import { icon } from 'lib/utils'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from 'lib/components/flash.svelte'
  import Spinner from 'modules/general/components/spinner.svelte'
  import extractIsbns from 'modules/inventory/lib/import/extract_isbns'
  onMount(() => autosize(document.querySelector('textarea')))

  let hideFlashIsbns, showFlashIsbns, isbnSpinner
  let validIsbns = [], allIsbns = [], invalidIsbns = []

  const onIsbnsChange = async value => {
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    hideFlashIsbns()
    allIsbns = extractIsbns(value)
    invalidIsbns = allIsbns.filter(_.property('isInvalid'))
    validIsbns = _.difference(allIsbns, invalidIsbns)
    if (invalidIsbns.length > 0) {
      const invalidRawIsbns = invalidIsbns.map(_.property('rawIsbn'))
      const message = `${I18n('invalid_isbns_warning')} ${invalidRawIsbns.join(', ')}`
      // to inventaire-i18n:
      // "invalid_isbns_warning": "those isbns are invalid (mistyping?), they will be ignored if continuing:"
      showFlashIsbns({
        priority: 'warning',
        message
      })
    }
  }
</script>

<section>
  <h3>1/ {I18n('import from a list of ISBNs')}</h3>
  <div id="isbnsImporter">
    <div class="textarea-wrapper">
      <textarea aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:keyup="{e => onIsbnsChange(e.target.value)}"></textarea>
      <a id="emptyIsbns" title="{i18n('clear')}">{@html icon('trash-o')}</a>
    </div>
    <Flash bind:show={showFlashIsbns} bind:hide={hideFlashIsbns}/>
    {#if isbnSpinner}
      <p class="loading">Loading... <Spinner/></p>
    {/if}
    <div><span class="warning"></span></div>
    <div class="loading"></div>
    <a id="findIsbns" class="success-button">{I18n('find ISBNs')}</a>
  </div>
</section>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
</style>
