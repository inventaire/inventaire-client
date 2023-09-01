<script>
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { uniq, without } from 'underscore'

  export let entity, property, value

  const rolesProperties = [
    'wdt:P50',
    'wdt:P58',
    'wdt:P98',
    'wdt:P110',
    'wdt:P6338',
  ]

  let currentRoleProperty = property

  async function onRolePropertyChange () {
    if (currentRoleProperty !== property) {
      entity.claims[property] = without(entity.claims[property], value)
      entity.claims[currentRoleProperty] = uniq(entity.claims[currentRoleProperty].concat([ value ]))
      await preq.put(app.API.entities.claims.update, {
        uri: entity.uri,
        property,
        'old-value': value,
        'new-value': null,
      })
      await preq.put(app.API.entities.claims.update, {
        uri: entity.uri,
        property: currentRoleProperty,
        'old-value': null,
        'new-value': value,
      })
    }
  }

  $: onChange(currentRoleProperty, onRolePropertyChange)
</script>

<label>
  {i18n('Change author role')}
  <select bind:value={currentRoleProperty}>
    {#each rolesProperties as roleProperty}
      <option value={roleProperty}>{I18n(roleProperty)}</option>
    {/each}
  </select>
</label>

<style lang="scss">
  @import "#general/scss/utils";
  select{
    margin-inline-start: auto;
    margin: 0 0.5em;
    height: 2rem;
    max-width: 10em;
  }
</style>
