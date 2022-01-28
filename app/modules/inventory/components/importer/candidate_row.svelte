<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyString } from '#lib/boolean_tests'
  import ListItem from '#inventory/components/list_item.svelte'
  export let candidate

  let disabled, existingItemsCount
  const { isbnData, works, customAuthorName, customWorkTitle } = candidate

  const rawIsbn = isbnData?.rawIsbn
  let needInfo, confirmInfo
  let alreadyItemsCount
  let checked = true

  $: {
    if (!works || works.length === 0) {
      if (customWorkTitle) {
        confirmInfo = true
      } else {
        needInfo = true
        disabled = true
      }
    } else {
      candidate.checked = true
    }
  }

  const onCheckSelect = e => {
    candidate.checked = e.target.checked
  }

  if (isbnData?.isInvalid) disabled = true

  $: {
    // must call candidate to be reactive
    if (disabled && candidate) candidate.checked = false
  }
  $: {
    // only set checked at existingItemsCount creation which happens after candidate creation
    // to allow user to check the box again
    alreadyItemsCount = existingItemsCount
    existingItemsCount = candidate.existingItemsCount
    if (!alreadyItemsCount && existingItemsCount) candidate.checked = false
  }
  $: checked = candidate.checked
  $: candidate.customWorkTitle = customWorkTitle
  $: candidate.customAuthorName = customAuthorName
  $: {
    if (isNonEmptyString(customWorkTitle)) {
      disabled = false
      candidate.checked = true
    } else {
      if (needInfo) {
        disabled = true
        candidate.checked = false
      }
    }
  }
</script>
<li class="candidateRow" class:checked>
  <ListItem bind:candidate/>
  <div class="checkbox">
    <input type="checkbox" bind:checked on:click={onCheckSelect} {disabled} name="{I18n('select_book')} {rawIsbn}">
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
