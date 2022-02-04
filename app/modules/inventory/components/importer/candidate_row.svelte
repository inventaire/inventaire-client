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
  <div class="candidateText">
    <div class="listItemWrapper">
      <ListItem bind:candidate/>
    </div>
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
        <div>{I18n('make sure information is correct')}</div>
      {/if}
      {#if existingItemsCount && !status.error && !item}
        <span class="existing-entity-items">
          {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
        </span>
      {/if}
    </div>
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
  .status{
    @include radius;
    background-color: $light-grey;
    margin: 0.2em;
    padding: 0.5em;
    flex: 1 0 0;
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
