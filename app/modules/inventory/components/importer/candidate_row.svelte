<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { isNonEmptyString } from '#lib/boolean_tests'
  import { preCandidateUri } from '#inventory/lib/import_helpers'
  import EntityLogo from './entity_source_logo.svelte'
  export let candidate

  let editionLang, work, disabled, existingItemsCount
  const { preCandidate, edition, works, authors } = candidate
  if (works && works.length > 0) work = works[0]
  const { isbnData } = preCandidate
  const rawIsbn = isbnData?.rawIsbn
  let needInfo, confirmInfo, existingItemsPathname, warning
  let alreadyItemsCount
  let customWorkTitle = preCandidate.title
  let customAuthorName

  const { authors: importedAuthors } = preCandidate

  if (edition) {
    editionLang = getOriginalLang(edition.claims)
  } else {
    editionLang = 'en'
  }

  if (importedAuthors && importedAuthors.length > 0) {
    customAuthorName = importedAuthors[0]
    if (importedAuthors.length > 1) {
      warning = 'multiple authors detected, currently only one author can be created now, you may edit created work authors later.'
    }
  }

  onMount(() => {
    if (existingItemsCount && existingItemsCount > 0) {
      const uri = preCandidateUri(preCandidate)
      const username = app.user.get('username')
      existingItemsPathname = `/inventory/${username}/${uri}`
      candidate.checked = false
    } else if (!works || works.length === 0) {
      if (customWorkTitle) {
        confirmInfo = true
      } else {
        needInfo = true
        disabled = true
      }
    } else {
      candidate.checked = true
    }
  })

  const findBestLang = objectWithLabels => {
    if (!objectWithLabels || !objectWithLabels.labels) return
    return getBestLangValue(editionLang, null, objectWithLabels.labels).value
  }

  const onCheckSelect = e => {
    candidate.checked = e.target.checked
  }

  if (isbnData?.isInvalid) disabled = true
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
  <div class="data">
    <div class="column work">
      <span class="label">{i18n('title')}:</span>
      {#if work}
        <span class="workTitle">
          {findBestLang(work, editionLang)}
          <EntityLogo uri="{work.uri}"/>
        </span>
      {:else}
        <input
          type="text"
          name="customWorkTitle"
          class="customInput"
          bind:value={customWorkTitle}
          placeholder="{I18n('write book title')}">
      {/if}
    </div>
    <span class="column authors">
      <span class="label">{i18n('authors')}:</span>
      {#if authors}
        {#each authors as author, id}
          <span class="authorName">
            {findBestLang(author)}
            <EntityLogo uri="{author.uri}"/>
            {#if id !== authors.length - 1},&nbsp;{/if}
          </span>
        {/each}
      {:else }
        <input
          type="text"
          name="customAuthorName"
          class="customInput"
          bind:value={customAuthorName}
        >
      {/if}
    </span>
    <div class="column isbn">
      {#if rawIsbn}
        <span class="label">ISBN:</span>
        {rawIsbn}
      {/if}
    </div>
    <div class="column status">
      {#if isbnData?.isInvalid}
        <span class="invalid-isbn">{I18n('invalid ISBN')}</span>
      {/if}
      {#if needInfo}
        <div>{I18n('need more information')}</div>
      {/if}
      {#if warning}
        <div>{I18n(warning)}</div>
      {/if}
      {#if confirmInfo}
        <div>{I18n('edit incorrect information')}</div>
      {/if}
      {#if existingItemsCount}
        <span class="existing-entity-items">
          {@html I18n('existing_entity_items', { smart_count: existingItemsCount, pathname: existingItemsPathname })}
        </span>
      {/if}
    </div>
  </div>
  <div class="checkbox">
    <input type="checkbox" bind:checked on:click={onCheckSelect} {disabled} name="{I18n('select_book')} {rawIsbn}">
  </div>
</li>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .column{
    flex: 20 0 0;
    padding: 0.2em;
  }
  .candidateRow{
    @include display-flex(row, center, center);
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .data{
    @include display-flex(row, center, flex-start);
    flex: 1 0 0;
    .isbn{
      @include display-flex(column);
      text-align: right;
      flex: 5 0 0;
    }
    .status{
      @include display-flex(column);
      text-align: right;
      flex: 7 0 0;
    }
    .label{
      display: none;
    }
  }
  .checkbox{
    padding-left: 1em;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .authors, .work{
    @include display-flex(row, center, center, wrap);
      width: 100%;
    .customInput{
      width: 100%;
    }
  }

  /*Small screens*/
  @media screen and (max-width: 45em) {
    .data{
      @include display-flex(column);
      .column{
        text-align: left;
      }
      .isbn{
        @include display-flex(row, center);
      }
      .label{
        display: inline;
        color: $grey;
        margin-right: 0.5em;
      }
    }
  }
</style>
