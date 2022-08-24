<script>
  import Spinner from '#components/spinner.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { getTextDirection } from '#lib/active_languages'
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { expired } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import { indexBy } from 'underscore'

  export let entity

  const { uri } = entity

  let summaryData, summaries, summeriesPerLang, summeriesPerKey, flash, selectedSummary
  let waitingForSummariesData, waitingForText

  function getSummaries () {
    const refresh = entity.refreshTimestamp && !expired(entity.refreshTimestamp, 1000)
    if (summaries == null || refresh) {
      waitingForSummariesData = preq.get(app.API.data.summaries({ uri, refresh }))
        .then(res => {
          summaries = res.summaries
          summeriesPerLang = indexBy(summaries, 'lang')
          summeriesPerKey = indexBy(summaries, 'key')
          if (!selectedSummary) {
            const bestOption = getBestLangValue(app.user.lang, null, summeriesPerLang).value
            if (bestOption) selectedSummary = bestOption.key
          }
        })
        .catch(err => flash = err)
    }
  }

  // This will trigger the first call to getSummaries, and further calls when the entity changes
  $: onChange(entity, getSummaries)

  function getSummaryText ({ key, lang, sitelink }) {
    const { title } = sitelink
    waitingForText = preq.get(app.API.data.wikipediaExtract(lang, title))
      .then(res => {
        summeriesPerKey[key].text = res.extract
        // Force refresh
        summaryData = summeriesPerKey[selectedSummary]
      })
      .catch(err => flash = err)
  }

  function getText () {
    if (summeriesPerKey) {
      summaryData = summeriesPerKey[selectedSummary]
      if (!summaryData.text) getSummaryText(summaryData)
    }
  }
  $: onChange(selectedSummary, getText)
</script>

<div class="summary-wrapper">
  {#await waitingForSummariesData then}
    {#if summaries.length > 0}
      <div class="header">
        <span class="label">{I18n('summary')}</span>
        {#if summaries.length > 1}
          <select bind:value={selectedSummary}>
            {#each summaries as summary (summary.link)}
              <option value={summary.key}>{summary.name}</option>
            {/each}
          </select>
        {/if}
      </div>
      {#await waitingForText}
        <Spinner center={true} />
      {:then}
        {#if summaryData.text}
          <p id="summary-text" lang={summaryData.lang} dir={getTextDirection(summaryData.lang)} >
            {summaryData.text}
            <span class="source">
              <Link url={summaryData.link} text={`${i18n('Source:')} ${summaryData.name}`} classNames="link" />
            </span>
          </p>
        {/if}
      {/await}
    {/if}
  {/await}

  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .summary-wrapper{
    padding: 0.5em;
    @include radius;
    background-color: $off-white;
    :global(.spinner-centered){
      padding: 2em;
    }
  }
  .header{
    @include display-flex(row, baseline, space-between);
  }
  .label{
    color: $label-grey;
    margin-inline-start: 0.5em;
  }
  select{
    max-width: 15em;
  }
  #summary-text{
    padding: 0.5em 0.5em 0 0.5em;
    max-height: 20em;
    overflow-y: auto;
  }
  .source{
    margin-inline-start: 1em;
    :global(a){
      color: $grey;
    }
  }
</style>
