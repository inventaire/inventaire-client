<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import EntryDisplay from '#inventory/components/entry_display.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { waitForAttribute } from '#lib/promises'
  import Flash from '#lib/components/flash.svelte'
  import { getUserExistingItemsPathname, statusContents } from '#inventory/components/importer/lib/candidate_row_helpers'
  import log_ from '#lib/loggers'

  export let candidate

  const { isbnData, edition, works, index: candidateId } = candidate
  let { editionTitle, authors, authorsNames } = candidate
  let work
  if (isNonEmptyArray(works)) work = works[0]
  else work = { label: editionTitle }
  let existingItemsPathname, flash
  let statuses = []

  let isCheckedInitializing = true
  let checked = false

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
  if (hasImportedData && noCandidateEntities && !hasWorkWithoutAuthors) {
    addStatus(statusContents.newEntry)
  }

  $: {
    if (candidate.error) {
      flash = candidate.error
    }
  }

  let needInfo = true
  let itemsCountWereChecked = false
  const updateCandidateInfoStatus = () => {
    if (work?.uri || isNonEmptyString(editionTitle)) {
      removeStatus(statusContents.needInfo)
      needInfo = false
      if (itemsCountWereChecked && isCheckedInitializing) {
        isCheckedInitializing = false
        checked = true
      }
    } else {
      addStatus(statusContents.needInfo)
      needInfo = true
    }
  }

  const waitingForItemsCount = waitForAttribute(candidate, 'waitingForItemsCount', { attemptTimeout: 200, maxAttempts: 500 })

  let existingItemsCount
  waitingForItemsCount
    .then(() => {
      existingItemsCount = candidate.existingItemsCount
      itemsCountWereChecked = true
      if (existingItemsCount && existingItemsCount > 0) {
        existingItemsPathname = getUserExistingItemsPathname(isbnData)
        checked = false
      } else {
        // Let updateCandidateInfoStatus evaluate if the candidate should be checked or not
        updateCandidateInfoStatus()
      }
    })
    .catch(err => {
      // Checking existing items is an enhancement, but not a requirement
    // If that check fails, no need to alert the user
      log_.error(err)
      itemsCountWereChecked = true
    })

  $: onChange(work, updateCandidateInfoStatus)
  $: onChange(editionTitle, updateCandidateInfoStatus)

  const updateCandidateCheckedStatus = () => candidate.checked = checked
  // Typically triggered when the checkbox is toggled
  $: onChange(checked, updateCandidateCheckedStatus)

  const updateLocalCheckedStatus = () => {
    // Prevent assignment loop
    if (checked === candidate.checked) return
    checked = candidate.checked
  }
  // Typically triggered when the CandidatesNav checks or unchecks all
  $: onChange(candidate.checked, updateLocalCheckedStatus)

  $: candidate.editionTitle = editionTitle
  $: candidate.authors = authors
  $: candidate.works = [ work ]
  $: disabled = (!itemsCountWereChecked) || needInfo || (candidate.error != null)
  $: if (disabled) checked = false
</script>

<li class="candidate-row" class:checked>
  <label title={disabled ? I18n(statuses[0]) : I18n('select_book')} for={`${candidateId}-checkbox`} class:disabled>
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
          <Flash
            state={{
              type: 'loading',
              message: i18n('Checking for existing items…')
            }} />
        {/await}
      {/if}
    </div>
    <input
      type="checkbox"
      id={`${candidateId}-checkbox`}
      bind:checked
      {disabled}
      title={I18n('select_book')}
    />
  </label>
  <Flash state={flash} />
</li>
<style lang="scss">
  @import "#general/scss/utils";
  .candidate-row{
    @include radius;
    border: solid 1px #ccc;
    padding: 0.2em 1em;
    margin-block-end: 0.2em;
  }
  label{
    @include display-flex(row, center, space-between);
    &:not(.disabled){
      cursor: pointer;
    }
    // Override global label rules
    font-size: inherit;
    color: inherit;
  }
  .list-item-wrapper{
    flex: 5 0 0;
    width: 100%;
  }
  .candidate-text{
    @include display-flex(column, center);
    margin-inline-end: 1em;
    width: 100%;
    :global(.flash){
      align-self: stretch;
    }
  }
  .status-row{
    width: 100%;
    padding: 0.3em 0.5em;
    margin-block-start: 0.3em;
  }
  .status{
    font-size: 0.9rem;
    :global(.link){
      text-decoration: underline;
    }
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .warning{
    background-color: lighten($yellow, 30%);
  }
  /* Small screens */
  @media screen and (width < 470px){
    .candidate-text{
      @include display-flex(column, center, space-between);
    }
  }
</style>
