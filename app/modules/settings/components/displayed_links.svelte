<script lang="ts">
  import { debounce, difference, intersection, uniq } from 'underscore'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { onChange } from '#app/lib/svelte/svelte'
  import { getPropertiesFromWebsitesNames, getWebsitesNamesFromProperties, websitesByCategoryAndName } from '#entities/lib/entity_links'
  import { I18n } from '#user/lib/i18n'

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
          value: customProperties,
        })
      }
    } catch (err) {
      // Ignore duplicated requests errors, as that should most likely
      // mean the latest request sent the same state as the previous request
      if (err.statusCode !== 429) flash = err
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

<section>
  <label class="category">
    <input
      type="checkbox"
      checked={selectedBibliographicDatabasesCount === bibliographicDatabasesNames.length}
      indeterminate={selectedBibliographicDatabasesCount !== 0 && selectedBibliographicDatabasesCount !== bibliographicDatabasesNames.length}
      on:click={() => toggleAllSection({ names: bibliographicDatabasesNames, selectedCount: selectedBibliographicDatabasesCount })}
    />
    {I18n('bibliographic databases')}
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

<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  section{
    margin-block-end: 1em;
    @include shy-border;
    @include radius;
  }
  fieldset{
    @include display-flex(row, null, null, wrap);
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
    width: min(15em, 80vw);
    padding: 0.5em;
  }
</style>
