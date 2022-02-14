<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
  import ListItem from '#inventory/components/list_item.svelte'
  export let candidate
  import { guessUriFromIsbn } from '#inventory/lib/import_helpers'

  const { isbnData, edition, works, authors, error, item } = candidate
  let { customWorkTitle, customAuthorsNames } = candidate
  const initialWorkTitle = customWorkTitle

  let existingItemsPathname
  let disabled, existingItemsCount
  const rawIsbn = isbnData?.rawIsbn
  let alreadyItemsCount
  let status = {}
  let anyStatus

  candidate.checked = true

  const hasImportedData = customWorkTitle || customAuthorsNames
  const noCandidateEntities = !isNonEmptyArray(works) || !isNonEmptyArray(authors)
  const hasWorkWithoutAuthors = isNonEmptyArray(works) && !isNonEmptyArray(authors)
  if (hasImportedData && noCandidateEntities && !hasWorkWithoutAuthors) status.confirmInfo = true

  if (isbnData?.isInvalid) {
    status.isInvalid = true
    disabled = true
  }

  if (isNonEmptyArray(customAuthorsNames)) {
    if (!authors && customAuthorsNames.length > 1) {
      status.warning = 'multiple authors detected, this importer can only create one author. You may add authors later.'
    }
  }

  $: {
    if (!works || works.length === 0) {
      if (isNonEmptyString(customWorkTitle)) {
        if (!status.confirmInfo) candidate.checked = true
        // confirm info disappear once user has modified info
        if (initialWorkTitle !== customWorkTitle) status.confirmInfo = false
        status.needInfo = false
        disabled = false
      } else {
        status.needInfo = true
        disabled = true
        candidate.checked = false
      }
    }
  }
  $: {
    if (disabled) candidate.checked = false
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
  $: candidate.customWorkTitle = customWorkTitle
  $: {
    const statusValues = Object.values(status)
    if (isNonEmptyArray(statusValues)) {
      anyStatus = statusValues.includes(true)
    } else {
      anyStatus = false
    }
  }
</script>
<li class="candidateRow" on:click="{() => candidate.checked = !candidate.checked}" class:checked>
  <div class="candidateText">
    <div class="listItemWrapper">
      <ListItem
        {isbnData}
        {edition}
        {works}
        {authors}
        bind:customWorkTitle
        bind:customAuthorsNames
        withEditor={true}
        />
    </div>
    {#if anyStatus}
      <div class="statuses">
        {#if status.isInvalid}
          <div class="status">{I18n('invalid ISBN')}</div>
        {/if}
        {#if status.needInfo}
          <div class="status">{I18n('need more information')}</div>
        {/if}
        {#if status.warning}
          <div class="status">{I18n()}</div>
        {/if}
        {#if status.confirmInfo}
          <div class="status">{I18n('make sure information is correct')}</div>
        {/if}
      </div>
    {/if}
    {#if error}
      <div class="statuses status">
        {I18n('error:')} {error.status_verbose}
      </div>
    {/if}
    {#if existingItemsCount && !status.error && !item}
      <div class="statuses status">
        {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
      </div>
    {/if}
  </div>
  <input type="checkbox" bind:checked {disabled} name="{I18n('select_book')} {rawIsbn}">
</li>
<style lang="scss">
  @import '#general/scss/utils';
  .candidateRow{
    @include display-flex(row, center, space-between);
    @include radius;
    border: solid 1px #ccc;
    padding: 0.2em 1em;
    margin-bottom: 0.2em;
  }
  .candidateText{
    width: 100%;
    margin-right: 1em;
    @include display-flex(row, center);
  }
  .listItemWrapper{
    flex: 5 0 0;
  }
  .statuses{
    flex: 1 0 0;
    @include display-flex(column, center);
  }
  .status{
    @include radius;
    background-color: $light-grey;
    margin: 0.2em;
    padding: 0.5em;
    text-align: center;
    font-size: 90%;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .candidateText{
      @include display-flex(column, center, space-between);
    }
  }
</style>
