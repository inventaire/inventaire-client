<script>
  import { I18n } from '#user/lib/i18n'
  import { linksClaimsPropertiesByCategory } from '#entities/lib/entity_links'
  import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
  import { onChange } from '#lib/svelte/svelte'
  import Flash from '#lib/components/flash.svelte'
  import { debounce } from 'underscore'

  export let linksSettings = app.user.get('customProperties') || []
  export let entityType

  const typeProperties = Object.keys(propertiesPerType[entityType])

  let linksClaimsPropertiesByCategoryAndType = linksClaimsPropertiesByCategory

  const isTypeProperty = propertyData => typeProperties.includes(propertyData.property)

  const filterLinksByEntityType = () => {
    for (const [ category, propertiesData ] of Object.entries(linksClaimsPropertiesByCategory)) {
      linksClaimsPropertiesByCategoryAndType[category] = propertiesData.filter(isTypeProperty)
    }
  }

  if (entityType) filterLinksByEntityType()

  const { bibliographicDatabases, socialNetworks } = linksClaimsPropertiesByCategoryAndType

  let flash

  async function updateCustomProperties () {
    flash = null
    try {
      await app.request('user:update', {
        attribute: 'customProperties',
        value: linksSettings
      })
    } catch (err) {
      flash = err
    }
  }

  const lazyUpdate = debounce(updateCustomProperties, 1000)
  $: onChange(linksSettings, lazyUpdate)
</script>

<fieldset>
  <legend>{I18n('bibliographic databases')}</legend>
  {#each bibliographicDatabases as option}
    <label>
      <input type="checkbox" bind:group={linksSettings} value={option.property}>
      {option.label}
    </label>
  {/each}
</fieldset>

<fieldset>
  <legend>{I18n('social networks')}</legend>
  {#each socialNetworks as option}
    <label>
      <input type="checkbox" bind:group={linksSettings} value={option.property}>
      {option.label}
    </label>
  {/each}
</fieldset>
<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
  fieldset{
    @include display-flex(row, null, null, wrap);
  }
  label{
    width: 10em;
    padding: 0.5em;
    margin: 0.1em;
    cursor: pointer;
  }
</style>
