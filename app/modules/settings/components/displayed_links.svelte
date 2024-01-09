<script>
  import { I18n } from '#user/lib/i18n'
  import { getPropertiesFromWebsitesNames, getWebsitesNamesFromProperties, websitesByCategoryAndName } from '#entities/lib/entity_links'
  import { onChange } from '#lib/svelte/svelte'
  import Flash from '#lib/components/flash.svelte'
  import { debounce, difference, intersection, uniq } from 'underscore'

  export let category = null

  const { bibliographicDatabases, socialNetworks } = websitesByCategoryAndName

  const bibliographicDatabasesNames = Object.keys(bibliographicDatabases)
  const socialNetworksNames = Object.keys(socialNetworks)

  let selectedBibliographicDatabasesCount = 0
  let selectedSocialNetworksCount = 0

  let customProperties = app.user.get('customProperties') || []
  let stringifiedSavedCustomProperties = JSON.stringify(customProperties)

  let selectedWebsites = getWebsitesNamesFromProperties(customProperties)
  let flash

  async function updateCustomProperties () {
    flash = null
    try {
      const stringifiedProperties = JSON.stringify(customProperties)
      if (stringifiedProperties !== stringifiedSavedCustomProperties) {
        stringifiedSavedCustomProperties = stringifiedProperties
        await app.request('user:update', {
          attribute: 'customProperties',
          value: customProperties
        })
      }
    } catch (err) {
      flash = err
    }
  }

  const lazyUpdate = debounce(updateCustomProperties, 1000)
  function onSelectionChange () {
    customProperties = getPropertiesFromWebsitesNames(selectedWebsites)
    selectedBibliographicDatabasesCount = intersection(bibliographicDatabasesNames, selectedWebsites).length
    selectedSocialNetworksCount = intersection(socialNetworksNames, selectedWebsites).length
    lazyUpdate()
  }
  $: onChange(selectedWebsites, onSelectionChange)

  function toggleAllSection ({ names, selectedCount }) {
    if (selectedCount !== names.length) {
      selectedWebsites = uniq(selectedWebsites.concat(names))
    } else {
      selectedWebsites = difference(selectedWebsites, names)
    }
  }
</script>

{#if category == null || category === 'bibliographicDatabases'}
  <section>
    <label class="category">
      <input
        type="checkbox"
        checked={selectedBibliographicDatabasesCount === bibliographicDatabasesNames.length}
        indeterminate={selectedBibliographicDatabasesCount !== 0 && selectedBibliographicDatabasesCount !== bibliographicDatabasesNames.length}
        on:click={() => toggleAllSection({ names: bibliographicDatabasesNames, selectedCount: selectedBibliographicDatabasesCount })}
      />
      {#if category != null}
        {I18n('all')}
      {:else}
        {I18n('bibliographic databases')}
      {/if}
    </label>
    <fieldset>
      {#each bibliographicDatabasesNames as websiteName}
        <label>
          <input type="checkbox" bind:group={selectedWebsites} value={websiteName} />
          {websiteName}
        </label>
      {/each}
    </fieldset>
  </section>
{/if}

{#if category == null || category === 'socialNetworksCount'}
  <section>
    <label class="category">
      <input
        type="checkbox"
        checked={selectedSocialNetworksCount === socialNetworksNames.length}
        indeterminate={selectedSocialNetworksCount !== 0 && selectedSocialNetworksCount !== socialNetworksNames.length}
        on:click={() => toggleAllSection({ names: socialNetworksNames, selectedCount: selectedSocialNetworksCount })}
      />
      {I18n('social networks')}
    </label>
    <fieldset>
      {#each socialNetworksNames as websiteName}
        <label>
          <input type="checkbox" bind:group={selectedWebsites} value={websiteName} />
          {websiteName}
        </label>
      {/each}
    </fieldset>
  </section>
{/if}

<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  section{
    margin-block-end: 1em;
    @include shy-border;
    @include radius;
  }
  fieldset{
    columns: 15rem auto;
  }
  .category{
    font-weight: bold;
    font-size: 1rem;
    padding: 0.5em;
    background-color: $lighter-grey;
  }
  label:not(.category){
    font-size: 1rem;
    @include display-flex(row, center);
    padding: 0.5em;
  }
</style>
