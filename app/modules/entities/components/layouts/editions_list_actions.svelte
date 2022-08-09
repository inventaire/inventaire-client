<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { getLangEntities, getPublishersEntities, hasPublisher } from '#entities/components/lib/editions_list_actions_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte'

  export let editions,
    hasSomeInitialEditions,
    initialEditions

  let flash
  let userLang = app.user.lang
  let selectedLang = userLang
  let selectedPublisher = 'all'

  let editionsLangs, langEntitiesLabel
  const waitingForLangEntities = getLangEntities(initialEditions)
    .then(res => ({ editionsLangs, langEntitiesLabel } = res))
    .catch(err => flash = err)

  let publishersUris, publishersLabels, someEditionsHaveNoPublisher
  const waitingForPublishersEntities = getPublishersEntities(initialEditions)
    .then(res => ({ publishersUris, publishersLabels, someEditionsHaveNoPublisher } = res))
    .catch(err => flash = err)

  const refreshFilters = () => {
    let displayedEntities = initialEditions
    if (selectedLang !== 'all') {
      displayedEntities = displayedEntities.filter(hasSelectedLang(selectedLang))
    }

    if (selectedPublisher === 'unknown') {
      displayedEntities = displayedEntities.filter(hasPublisher('unknown'))
    } else if (selectedPublisher !== 'all') {
      displayedEntities = displayedEntities.filter(hasPublisher(selectedPublisher))
    }

    editions = displayedEntities
  }

  const langEditionsCount = lang => initialEditions.filter(hasSelectedLang(lang)).length
  const publisherCount = uri => initialEditions.filter(hasPublisher(uri)).length

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]

  $: onChange(initialEditions, selectedLang, selectedPublisher, refreshFilters)
</script>
{#if hasSomeInitialEditions}
  <div class="filters">
    <span class="filters-header">{i18n('Filter by')}</span>

    {#await waitingForLangEntities}
      <Spinner/>
    {:then}
      {#if editionsLangs.length > 0}
        <label>
          {I18n('language')}
          <select name="language" bind:value={selectedLang}>
            <option value="all">{I18n('all languages')} ({initialEditions.length})</option>
            {#each editionsLangs as lang}
              <option value={lang}>{lang} - {getLangLabel(lang)} ({langEditionsCount(lang)})</option>
            {/each}
          </select>
        </label>
      {/if}
    {/await}

    {#await waitingForPublishersEntities}
      <Spinner/>
    {:then}
      {#if editionsLangs.length > 0}
        <label>
          {I18n('publisher')}
          <select name="publisher" bind:value={selectedPublisher}>
            <option value="all">{I18n('all publishers')} ({initialEditions.length})</option>
            {#if publishersUris}
            {#each publishersUris as uri}
              <option value={uri}>{publishersLabels[uri]} ({publisherCount(uri)})</option>
            {/each}
            {/if}
            {#if someEditionsHaveNoPublisher}
              <option value="unknown">{I18n('unknown')} ({publisherCount('unknown')})</option>
            {/if}
          </select>
        </label>
      {/if}
    {/await}
  </div>
  <Flash state={flash} />
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .filters{
    @include display-flex(row, center, flex-start);
    align-self: stretch;
  }
  .filters-header{
    margin: 0.5em;
    align-self: flex-end;
    color: $label-grey;
  }
  label{
    margin: 0 1em;
  }
</style>
