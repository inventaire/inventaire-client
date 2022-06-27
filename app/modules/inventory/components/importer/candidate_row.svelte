<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import EntryDisplay from '#inventory/components/entry_display.svelte'
  export let candidate
  import { guessUriFromIsbn } from '#inventory/lib/importer/import_helpers'
  import { onChange } from '#lib/svelte'
  import { waitForAttribute } from '#lib/promises'
  import Flash from '#lib/components/flash.svelte'

  const { isbnData, edition, works, error } = candidate
  let { editionTitle, authors, authorsNames } = candidate
  let work
  if (isNonEmptyArray(works)) work = works[0]
  else work = { label: editionTitle }
  let existingItemsPathname
  let disabled
  let statuses = []

  let checked = false
  $: candidate.checked = checked

  const statusContents = {
    newEntry: 'We could not identify this entry in the common bibliographic database. A new entry will be created',
    error: 'oups, something wrong happened',
    invalid: 'invalid ISBN',
    needInfo: 'need more information',
  }

  const addStatus = status => {
    if (!statuses.includes(status)) {
      statuses.push(status)
      statuses = statuses
    }
  }

  const removeStatus = status => {
    statuses = _.without(statuses, status)
  }

  const hasImportedData = editionTitle || authorsNames
  const noCandidateEntities = !work.uri && !(authors?.every(_.property('uri')))
  const hasWorkWithoutAuthors = work.uri && !isNonEmptyArray(authors)
  // TODO: remove newEntry status if work and authors both have entities uris
  if (hasImportedData && noCandidateEntities && !hasWorkWithoutAuthors) addStatus(statusContents.newEntry)
  if (error) addStatus(statusContents.error)
  if (isbnData?.isInvalid) addStatus(statusContents.invalid)

  if (isNonEmptyArray(statuses)) disabled = true

  let itemsCountWereChecked = false
  const updateCandidateInfoStatus = () => {
    if (work?.uri || isNonEmptyString(editionTitle)) {
      removeStatus(statusContents.needInfo)
      disabled = false
      if (itemsCountWereChecked) checked = true
    } else {
      addStatus(statusContents.needInfo)
      disabled = true
    }
  }
  $: onChange(work, updateCandidateInfoStatus)
  $: onChange(editionTitle, updateCandidateInfoStatus)
  $: if (disabled) checked = false

  const toggleCheckbox = () => {
    if (!disabled) checked = !checked
  }

  const waitingForItemsCount = waitForAttribute(candidate, 'waitingForItemsCount', 200)

  let existingItemsCount
  waitingForItemsCount.then(() => {
    existingItemsCount = candidate.existingItemsCount
    itemsCountWereChecked = true
    if (existingItemsCount && existingItemsCount > 0) {
      const uri = guessUriFromIsbn({ isbnData })
      const username = app.user.get('username')
      existingItemsPathname = `/inventory/${username}/${uri}`
      checked = false
    } else {
      // Let updateCandidateInfoStatus evaluate if the candidate should be checked or not
      updateCandidateInfoStatus()
    }
  })
  $: candidate.editionTitle = editionTitle
  $: candidate.authors = authors
  $: candidate.works = [ work ]
</script>
<li class="candidate-row" on:click={toggleCheckbox} role="button" class:checked>
  <div class="candidate-text">
    <div class="list-item-wrapper">
      <EntryDisplay
        {isbnData}
        {edition}
        bind:work
        {authorsNames}
        bind:authors
        bind:editionTitle
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
    {:else}
      {#await waitingForItemsCount}
        <Flash state={{
          type: 'loading',
          message: i18n('Checking for existing items...')
        }} />
      {/await}
    {/if}
  </div>
  <input type="checkbox"
    bind:checked
    {disabled}
    title={I18n('select_book')}
  >
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
    :global(.flash){
      align-self: stretch;
    }
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
