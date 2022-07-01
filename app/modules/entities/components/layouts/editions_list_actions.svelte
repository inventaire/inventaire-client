<script>
  import Spinner from '#general/components/spinner.svelte'
  import { i18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/utils'
  import { getLang, hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { fetchLangEntities, getWdUri, prioritizeMainUserLang } from '#entities/components/lib/editions_list_actions_helpers'
  import { compact } from 'underscore'

  export let editions,
    someInitialEditions,
    initialEditions

  someInitialEditions = compact(someInitialEditions)

  let editionsLangs = []
  let langEntitiesLabel = {}, showDropdown
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

  const filterEditionByLang = _ => {
    editions = initialEditions.filter(hasSelectedLang(selectedLang))
  }

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]

  const selectAllLangs = () => {
    editions = initialEditions
    selectedLang = null
    showDropdown = false
  }

  $: selectedLang && filterEditionByLang(initialEditions)
</script>
{#if someInitialEditions}
  <div class="actions-wrapper">
    {#await waitingForEntities}
      <Spinner/>
    {:then}
      {#if editionsLangs.length > 0}
        <div class="menu-wrapper">
          <Dropdown
            buttonTitle={i18n('show langs')}
            align={'center'}
            bind:showDropdown={showDropdown}
          >
            <div slot="button-inner">
              {@html icon('language')}{i18n('filter by language')}
            </div>
            <ul slot="dropdown-content">
              {#each editionsLangs as lang}
                <li class="dropdown-element">
                  <label>
                    <input
                      type="radio"
                      bind:group={selectedLang}
                      value={lang}
                      on:click={() => {
                        selectedLang = lang
                        showDropdown = false
                      }}
                    />
                    {lang} - {getLangLabel(lang)}
                  </label>
                </li>
              {/each}
              <li class="dropdown-element">
                <label
                  on:click={selectAllLangs}
                  for='all languages'
                >
                  {i18n('all languages')}
                </label>
              </li>
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
      @include display-flex(row, center, flex-start);
      cursor:pointer;
      min-height: 3em;
      padding: 1em;
      width:100%
    }
    li{
      @include bg-hover(white, 10%);
      &:not(:last-child){
        margin-bottom: 0.2em;
      }
      :global(.error){
        flex: 1;
      }
    }
    input{
      // override _input.scss
      height: auto;
      width: auto;
      // prefer both right and left margin to fit left-to-right languages
      margin: 0 0.5em;
    }
  }
</style>
