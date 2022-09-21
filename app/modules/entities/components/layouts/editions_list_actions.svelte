<script>
  import Spinner from '#general/components/spinner.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { getLangEntities, getPublishersEntities, getPublicationYears, hasPublisher, hasPublicationYear } from '#entities/components/lib/editions_list_actions_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { getContext } from 'svelte'

  export let editions, initialEditions

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

<div class="filters">
  <span class="filters-header">{i18n('Filter by')}</span>

  {#await waitingForLangEntities}
    <Spinner/>
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
    <Spinner/>
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
<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .filters{
    @include display-flex(row, center, flex-start);
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
      padding-right: 2em;
    }
    label{
      margin-left: 0.8em;
      margin-bottom: 0.2em;
    }
    button{
      position: absolute;
      right: 0.1em;
      bottom: 0.1em;
      height: 2.1em;
      width: 2em;
      @include bg-hover(white);
      padding: 0;
    }
  }
  select.filtering{
    border-color: $glow;
  }
</style>
