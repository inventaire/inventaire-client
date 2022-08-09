<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { getLang, hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { fetchLangEntities, getWdUri, prioritizeMainUserLang } from '#entities/components/lib/editions_list_actions_helpers'
  import { compact } from 'underscore'

  export let editions,
    someInitialEditions,
    initialEditions

  someInitialEditions = compact(someInitialEditions)

  let editionsLangs = []
  let langEntitiesLabel = {}
  let userLang = app.user.lang
  let selectedLang = userLang

  const waitingForEntities = getLangEntities()

  async function getLangEntities () {
    let rawEditionsLangs = _.compact(_.uniq(initialEditions.map(getLang)))
    editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
    const langsUris = _.compact(editionsLangs.map(getWdUri))
    const entities = await fetchLangEntities(langsUris)
    editionsLangs.forEach(lang => {
      const langWdId = getWdUri(lang)
      if (langWdId) langEntitiesLabel[lang] = entities[langWdId]
    })
  }

  const filterEditionByLang = () => {
    if (selectedLang === 'all') {
      editions = initialEditions
    } else {
      editions = initialEditions.filter(hasSelectedLang(selectedLang))
    }
  }

  const langEditionsCount = lang => initialEditions.filter(hasSelectedLang(lang)).length

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]

  $: selectedLang && filterEditionByLang(initialEditions)
</script>
{#if someInitialEditions}
  <div class="filters">
    {#await waitingForEntities}
      <Spinner/>
    {:then}
      <span class="filters-header">{i18n('Filter by')}</span>
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
  </div>
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
