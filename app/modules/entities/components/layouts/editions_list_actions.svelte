<script>
  import Spinner from '#general/components/spinner.svelte'
  import { i18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/utils'
  import wdLang from 'wikidata-lang'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'

  export let selectedLangs,
    editionsLangs = [],
    someInitialEditions

  let langEntitiesLabel = {}

  const getWdUri = lang => {
    const langWdId = wdLang.byCode[lang]?.wd
    if (langWdId) return `wd:${langWdId}`
  }

  const waitingForEntities = getLangEntities()

  async function getLangEntities () {
    const langsUris = _.compact(editionsLangs.map(getWdUri))
    const { entities } = await getEntitiesAttributesByUris({
      uris: langsUris,
      attributes: [ 'labels' ],
      lang: app.user.lang
    })
    editionsLangs.forEach(lang => {
      const langWdId = getWdUri(lang)
      if (langWdId) langEntitiesLabel[lang] = entities[langWdId]
    })
  }

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]
</script>
{#if someInitialEditions}
  <div class="actions-wrapper">
    {#await waitingForEntities}
      <Spinner/>
    {:then}
      {#if editionsLangs.length > 1}
        <div class="menu-wrapper">
          <Dropdown
            buttonTitle={i18n('show langs')}
            align={'center'}
          >
            <div slot="button-inner">
              {@html icon('language')}{i18n('filter by language')}
            </div>
            <ul slot="dropdown-content">
              <li class="dropdown-element">
                <label
                  on:click={() => { selectedLangs = editionsLangs }}
                  for='all languages'
                >
                  {i18n('all languages')}
                </label>
              </li>
              {#each editionsLangs as lang}
                <li class="dropdown-element">
                  <label>
                    <input type="checkbox" bind:group={selectedLangs} value={lang} />
                    {lang} - {getLangLabel(lang)}
                  </label>
                </li>
              {/each}
            </ul>
          </Dropdown>
        </div>
      {/if}
    {/await}
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  // Dropdown
  .menu-wrapper{
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      margin-right: 0.5em;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      right: 0;
    }
    @include display-flex(column, flex-end);
    :global(.dropdown-button){
      @include tiny-button($light-grey, black);
      padding: 0.5em;
    }
  }
  [slot="dropdown-content"]{
    @include shy-border;
    @include radius;
    min-width: 5em;
    background-color:white;
    // z-index known cases: items map
    z-index: 1;
    position: relative;
    label{
      cursor:pointer;
      min-height: 3em;
      padding: 1em;
      width:100%
    }
    li{
      @include bg-hover(white, 10%);
      @include display-flex(row, center, flex-start);
      &:not(:last-child){
        margin-bottom: 0.2em;
      }
      :global(.error){
        flex: 1;
      }
    }
  }
</style>
