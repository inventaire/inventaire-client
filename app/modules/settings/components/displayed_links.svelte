<script>
  import { I18n } from '#user/lib/i18n'
  import { getPropertiesFromWebsitesNames, getWebsitesNamesFromProperties, websitesByCategoryAndName } from '#entities/lib/entity_links'
  import { onChange } from '#lib/svelte/svelte'
  import Flash from '#lib/components/flash.svelte'
  import { debounce } from 'underscore'

  const { bibliographicDatabases, socialNetworks } = websitesByCategoryAndName

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
      // Ignore duplicated requests errors, as that should most likely
      // mean the latest request sent the same state as the previous request
      if (err.statusCode !== 429) flash = err
    }
  }

  const lazyUpdate = debounce(updateCustomProperties, 1000)
  function onSelectionChange () {
    customProperties = getPropertiesFromWebsitesNames(selectedWebsites)
    lazyUpdate()
  }
  $: onChange(selectedWebsites, onSelectionChange)
</script>

<fieldset>
  <legend>{I18n('bibliographic databases')}</legend>
  {#each Object.keys(bibliographicDatabases) as websiteName}
    <label>
      <input type="checkbox" bind:group={selectedWebsites} value={websiteName} />
      {websiteName}
    </label>
  {/each}
</fieldset>
<fieldset>
  <legend>{I18n('social networks')}</legend>
  {#each Object.keys(socialNetworks) as websiteName}
    <label>
      <input type="checkbox" bind:group={selectedWebsites} value={websiteName} />
      {websiteName}
    </label>
  {/each}
</fieldset>
<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  fieldset{
    @include display-flex(row, null, null, wrap);
    margin-block-start: 0.5em;
  }
  legend{
    font-weight: bold;
  }
  label{
    width: min(15em, 80vw);
    padding: 0.5em;
    font-size: 1rem;
    cursor: pointer;
    @include display-flex(row, center);
  }
</style>
