<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import EntryDisplay from '#inventory/components/entry_display.svelte'
  export let candidate
  import { guessUriFromIsbn } from '#inventory/lib/import_helpers'

  const { isbnData, edition, works, authors, error } = candidate
  let { workTitle, authorsNames } = candidate

  let existingItemsPathname
  let disabled, existingItemsCount
  const rawIsbn = isbnData?.rawIsbn
  let alreadyItemsCount
  let statuses = []

  candidate.checked = true

  const statusContents = {
    newEntry: 'We could not identify this entry in the common bibliographic database. A new entry will be created',
    error: 'oups, something wrong happened',
    invalid: 'invalid ISBN',
    multipleAuthors: 'multiple authors detected, this importer can only create one author. You may add authors later.',
    needInfo: 'need more information',
  }

  const addStatus = status => {
    statuses.push(status)
    statuses = statuses
  }

  const removeStatus = status => {
    statuses = _.without(statuses, status)
  }

  const hasImportedData = workTitle || authorsNames
  const noCandidateEntities = !isNonEmptyArray(works) || !isNonEmptyArray(authors)
  const hasWorkWithoutAuthors = isNonEmptyArray(works) && !isNonEmptyArray(authors)
  if (hasImportedData && noCandidateEntities && !hasWorkWithoutAuthors) addStatus(statusContents.newEntry)
  if (error) addStatus(statusContents.error)
  if (isbnData?.isInvalid) addStatus(statusContents.invalid)
  if (isNonEmptyArray(authorsNames)) {
    if (!authors && authorsNames.length > 1) {
      addStatus(statusContents.multipleAuthors)
    }
  }

  if (isNonEmptyArray(statuses)) { disabled = true }

  const toggleCheckbox = () => {
    if (!disabled) candidate.checked = !candidate.checked
  }

  $: {
    if (!isNonEmptyArray(works) && !isNonEmptyString(workTitle)) {
      addStatus(statusContents.needInfo)
      disabled = true
    } else {
      removeStatus(statusContents.needInfo)
      disabled = false
      candidate.checked = true
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
  $: candidate.workTitle = workTitle
</script>
<li class="candidate-row" on:click="{toggleCheckbox}" class:checked>
  <div class="candidate-text">
    <div class="list-item-wrapper">
      <EntryDisplay
        {isbnData}
        {edition}
        {works}
        {authors}
        bind:workTitle
        bind:authorsNames
        withEditor={true}
        />
    </div>
    {#if isNonEmptyArray(statuses) || existingItemsCount}
      <div class="status-row warning">
        <ul>
          {#each statuses as status}
            <li class="status">
              {@html icon('warning')} {I18n(status)}
            </li>
          {/each}
          {#if existingItemsCount}
            <li class="status">
              {@html icon('warning')} {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
            </li>
          {/if}
         </ul>
      </div>
    {/if}
  </div>
  <input type="checkbox" bind:checked {disabled} name="{I18n('select_book')} {rawIsbn}">
</li>
<style lang="scss">
  @import '#general/scss/utils';
  .candidate-row{
    @include display-flex(row, center, space-between);
    @include radius;
    border: solid 1px #ccc;
    padding: 0.2em 1em;
    margin-bottom: 0.2em;
  }
  .list-item-wrapper{
    flex: 5 0 0;
    width: 100%;
  }
  .candidate-text{
    @include display-flex(column, center);
    margin-right: 1em;
    width: 100%;
  }
  .status-row{
    width: 100%;
    padding: 0.3em 0.5em;
    margin-top: 0.3em;
  }
  .status{
    font-size: 90%;
    :global(.link) {
      text-decoration: underline;
    }
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .warning{
    background-color: lighten($yellow, 30%);
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .candidate-text{
      @include display-flex(column, center, space-between);
    }
  }
</style>
