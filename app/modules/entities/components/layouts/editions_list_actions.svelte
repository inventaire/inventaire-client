<script lang="ts">
  import { getContext } from 'svelte'
  import app from '#app/app'
  import SortEntitiesBy from '#entities/components/layouts/sort_entities_by.svelte'
  import { hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { getLangEntities, getPublishersEntities, getPublicationYears, hasPublisher, hasPublicationYear } from '#entities/components/lib/editions_list_actions_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/icons'
  import { onChange } from '#lib/svelte/svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let editions, initialEditions, waitingForItems

  const filters = getContext('work-layout:filters-store')

  let flash

  $filters.selectedLang = app.user.lang
  $filters.selectedPublisher = 'all'

  let editionsLangs, langEntitiesLabel
  const waitingForLangEntities = getLangEntities(initialEditions)
    .then(res => ({ editionsLangs, langEntitiesLabel } = res))
    .then(refreshFilters)
    .catch(err => flash = err)

  let publishersUris, publishersLabels, someEditionsHaveNoPublisher
  const waitingForPublishersEntities = getPublishersEntities(initialEditions)
    .then(res => ({ publishersUris, publishersLabels, someEditionsHaveNoPublisher } = res))
    .then(refreshFilters)
    .catch(err => flash = err)

  const { publicationYears, someEditionsHaveNoPublicationDate } = getPublicationYears(initialEditions)

  function unselectEmptyFilter () {
    if (initialEditions && langEditionsCount($filters.selectedLang) === 0) {
      $filters.selectedLang = 'all'
    }
  }

  function refreshFilters () {
    let displayedEntities = initialEditions
    if ($filters.selectedLang !== 'all') {
      displayedEntities = displayedEntities.filter(hasSelectedLang($filters.selectedLang))
    }

    if ($filters.selectedPublisher === 'unknown') {
      displayedEntities = displayedEntities.filter(hasPublisher('unknown'))
    } else if ($filters.selectedPublisher !== 'all') {
      displayedEntities = displayedEntities.filter(hasPublisher($filters.selectedPublisher))
    }

    if ($filters.selectedPublicationYear === 'unknown') {
      displayedEntities = displayedEntities.filter(hasPublicationYear('unknown'))
    } else if ($filters.selectedPublicationYear !== 'all') {
      displayedEntities = displayedEntities.filter(hasPublicationYear($filters.selectedPublicationYear))
    }

    editions = displayedEntities

    if (langEntitiesLabel) {
      $filters.selectedLangLabel = langEntitiesLabel[$filters.selectedLang]
    }
    if (publishersLabels) {
      if ($filters.selectedPublisher === 'unknown') {
        $filters.selectedPublisherLabel = `${I18n('unknown publisher')}`
      } else {
        $filters.selectedPublisherLabel = publishersLabels[$filters.selectedPublisher]
      }
    }
  }

  const langEditionsCount = lang => initialEditions.filter(hasSelectedLang(lang)).length
  const publisherCount = uri => initialEditions.filter(hasPublisher(uri)).length
  const publicationYearCount = year => initialEditions.filter(hasPublicationYear(year)).length

  $: onChange(initialEditions, unselectEmptyFilter)
  $: onChange(initialEditions, $filters, refreshFilters)
</script>

<div class="filters menu">
  <span class="filters-header">{i18n('Filter by')}</span>

  {#await waitingForLangEntities}
    <Spinner />
  {:then}
    {#if editionsLangs.length > 0}
      <div class="filter">
        <label for="language-filter">{I18n('language')}</label>
        <select
          id="language-filter"
          name="language"
          bind:value={$filters.selectedLang}
          class:filtering={$filters.selectedLang !== 'all'}
        >
          <option value="all">{I18n('all languages')} ({initialEditions.length})</option>
          {#each editionsLangs as lang}
            <option value={lang}>{lang} - {langEntitiesLabel[lang]} ({langEditionsCount(lang)})</option>
          {/each}
        </select>
        {#if $filters.selectedLang !== 'all'}
          <button
            title={I18n('reset filter')}
            aria-controls="language-filter"
            on:click={() => $filters.selectedLang = 'all'}
          >{@html icon('close')}</button>
        {/if}
      </div>
    {/if}
  {/await}

  {#await waitingForPublishersEntities}
    <Spinner />
  {:then}
    {#if publishersUris.length > 0}
      <div class="filter">
        <label for="publisher-filter">{I18n('publisher')}</label>
        <select
          id="publisher-filter"
          name="publisher"
          bind:value={$filters.selectedPublisher}
          class:filtering={$filters.selectedPublisher !== 'all'}
        >
          <option value="all">{I18n('all publishers')} ({initialEditions.length})</option>
          {#each publishersUris as uri}
            <option value={uri}>{publishersLabels[uri]} ({publisherCount(uri)})</option>
          {/each}
          {#if someEditionsHaveNoPublisher}
            <option value="unknown">{I18n('unknown')} ({publisherCount('unknown')})</option>
          {/if}
        </select>
        {#if $filters.selectedPublisher !== 'all'}
          <button
            title={I18n('reset filter')}
            aria-controls="publisher-filter"
            on:click={() => $filters.selectedPublisher = 'all'}
          >{@html icon('close')}</button>
        {/if}
      </div>
    {/if}
  {/await}

  <div class="filter">
    <label for="publication-year-filter">{I18n('publication year')}</label>
    <select
      id="publication-year-filter"
      name="publication-year"
      bind:value={$filters.selectedPublicationYear}
      class:filtering={$filters.selectedPublicationYear !== 'all'}
    >
      <option value="all">{I18n('any year')} ({initialEditions.length})</option>
      {#each publicationYears as year}
        <option value={year}>{year} ({publicationYearCount(year)})</option>
      {/each}
      {#if someEditionsHaveNoPublicationDate}
        <option value="unknown">{I18n('unknown')} ({publicationYearCount('unknown')})</option>
      {/if}
    </select>
    {#if $filters.selectedPublicationYear !== 'all'}
      <button
        title={I18n('reset filter')}
        aria-controls="publication-year-filter"
        on:click={() => $filters.selectedPublicationYear = 'all'}
      >{@html icon('close')}</button>
    {/if}
  </div>
</div>
{#if editions.length > 1}
  <div class="sort-selector-wrapper menu">
    <SortEntitiesBy
      sortingType="edition"
      bind:entities={editions}
      {waitingForItems}
    />
  </div>
{/if}
<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .sort-selector-wrapper{
    width: 100%;
    margin-block-start: 0.5em;
    :global(.sort-selector), :global(label){
      margin: 0 1em;
      margin-inline-start: 0;
      font-size: 100%;
      text-align: start;
    }
  }
  .menu{
    background-color: $light-grey;
    padding: 0.5em;
  }
  .filters{
    align-self: stretch;
  }
  .filters-header{
    margin: 0.5em 0;
    align-self: flex-end;
    color: $label-grey;
  }
  .filter{
    margin: 0 1em;
    position: relative;
    select{
      padding-inline-end: 2em;
    }
    label{
      margin-inline-start: 0.8em;
      margin-block-end: 0.2em;
    }
    button{
      position: absolute;
      inset-inline-end: 0.1em;
      inset-block-end: 0.1em;
      block-size: 2.1em;
      inline-size: 2em;
      @include bg-hover(white);
      padding: 0;
    }
  }
  select.filtering{
    border-color: $glow;
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    .filters{
      @include display-flex(row, center, flex-start);
    }
  }
</style>
