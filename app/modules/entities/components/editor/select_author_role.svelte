<script>
  import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
  import { getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { uniq, without } from 'underscore'

  export let entity, property, value

  let rolesProperties
  function setRolesProperties () {
    rolesProperties = getWorkPreferredAuthorRolesProperties(entity)
    if (!rolesProperties.includes(property)) {
      rolesProperties = [ property, ...rolesProperties ]
    }
    if (rolesProperties.length === 1 && rolesProperties[0] === property) {
      rolesProperties = null
    }
  }

  $: onChange(entity, setRolesProperties)

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

{#if rolesProperties && isNonEmptyClaimValue(value)}
  <label>
    {i18n('Change author role')}
    <select bind:value={currentRoleProperty}>
      {#each rolesProperties as roleProperty}
        {@const disabled = roleProperty !== property && entity.claims[roleProperty]?.includes(value)}
        <option
          value={roleProperty}
          {disabled}
          title={disabled ? i18n('This author already has that role') : ''}
        >
          {I18n(roleProperty)}
        </option>
      {/each}
    </select>
  </label>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  select{
    margin-inline-start: auto;
    margin: 0 0.5em;
    height: 2rem;
    width: auto;
  }
</style>
