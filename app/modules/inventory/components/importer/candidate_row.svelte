<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyString } from '#lib/boolean_tests'
  import ListItem from '#inventory/components/list_item.svelte'
  export let candidate
  import { guessUriFromIsbn } from '#inventory/lib/import_helpers'

  const { isbnData, works, error, item } = candidate

  let existingItemsPathname

  let disabled, existingItemsCount
  const rawIsbn = isbnData?.rawIsbn
  let alreadyItemsCount
  candidate.checked = true
  let status = {}

  if (isbnData?.isInvalid) disabled = true
  $: {
    if (!works || works.length === 0) {
      if (isNonEmptyString(candidate.customWorkTitle)) {
        if (!status.confirmInfo) candidate.checked = true
        status.confirmInfo = true
        status.needInfo = false
        disabled = false
      } else {
        status.confirmInfo = false
        status.needInfo = true
        disabled = true
        candidate.checked = false
      }
    }
  }
  $: {
    // must call candidate to be reactive
    if (disabled && candidate) candidate.checked = false
  }
  $: {
    if (existingItemsCount && existingItemsCount > 0) {
      const uri = guessUriFromIsbn({ isbnData })
      const username = app.user.get('username')
      existingItemsPathname = `/inventory/${username}/${uri}`
    }
  }
  $: {
    // only set checked at existingItemsCount creation which happens after candidate creation
    // to allow user to check the box again
    existingItemsCount = candidate.existingItemsCount
    if (!alreadyItemsCount && existingItemsCount) {
      candidate.checked = false
      alreadyItemsCount = true
    }
  }
  $: checked = candidate.checked
</script>
<li class="candidateRow" on:click="{() => candidate.checked = !candidate.checked}" class:checked>
  <ListItem bind:candidate/>
  <div class="column status">
    {#if isbnData?.isInvalid}
      <span class="invalid-isbn">{I18n('invalid ISBN')}</span>
    {/if}
    {#if error}
      <div>{I18n('error:')} {error.status_verbose}</div>
    {/if}
    {#if status.needInfo}
      <div>{I18n('need more information')}</div>
    {/if}
    {#if status.warning}
      <div>{I18n()}</div>
    {/if}
    {#if status.confirmInfo}
      <div>{I18n('edit incorrect information')}</div>
    {/if}
    {#if existingItemsCount && !status.error && !item}
      <span class="existing-entity-items">
        {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
      </span>
    {/if}
  </div>

  <div class="checkbox">
    <input type="checkbox" bind:checked {disabled} name="{I18n('select_book')} {rawIsbn}">
  </div>
</li>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .candidateRow{
    @include display-flex(row, center, center);
    margin: 0.2em 0;
    padding: 0.2em 1em;
    padding-left: 0.5em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .checkbox{
    padding-left: 1em;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
</style>
