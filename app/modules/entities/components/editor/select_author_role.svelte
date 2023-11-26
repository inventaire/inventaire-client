<script>
  import { addClaimValue, isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
  import { getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'
  import { getActionKey } from '#lib/key_events'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { icon } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import { createEventDispatcher, tick } from 'svelte'

  export let entity, property, value

  let showAuthorRoleSelector = false

  let selectorEl
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

  const dispatch = createEventDispatcher()

  $: onChange(entity, setRolesProperties)

  let currentRoleProperty = property

  async function onRolePropertyChange () {
    if (currentRoleProperty !== property) {
      // Keep a private copy as the value variable might be redefined
      // by parent components during async ops
      const movedValue = value
      dispatch('moved')
      entity.claims[currentRoleProperty] = addClaimValue(entity.claims[currentRoleProperty], movedValue)
      // If entity.uri is undefined, we are manipulating a not-yet-created entity
      if (entity.uri) {
        await preq.put(app.API.entities.claims.update, {
          uri: entity.uri,
          property,
          'old-value': movedValue,
          'new-value': null,
        })
        await preq.put(app.API.entities.claims.update, {
          uri: entity.uri,
          property: currentRoleProperty,
          'old-value': null,
          'new-value': movedValue,
        })
      }
    }
  }

  async function showSelector () {
    showAuthorRoleSelector = true
    await tick()
    selectorEl?.focus()
  }
  function hideSelector () {
    showAuthorRoleSelector = false
  }
  function onKeyDown (e) {
    if (getActionKey(e) === 'esc') hideSelector()
  }

  $: onChange(currentRoleProperty, onRolePropertyChange)
</script>

<div>
  {#if rolesProperties && isNonEmptyClaimValue(value)}
    {#if showAuthorRoleSelector}
      <select
        bind:value={currentRoleProperty}
        title={i18n('Change author role')}
        on:keydown={onKeyDown}
        bind:this={selectorEl}>
        {#each rolesProperties as roleProperty}
          {@const disabled = roleProperty !== property && entity.claims[roleProperty]?.includes(value)}
          <option
            value={roleProperty}
            {disabled}
            title={disabled ? i18n('This person already has that role') : ''}
          >
            {I18n(roleProperty)}
          </option>
        {/each}
      </select>
      <button class="hide" on:click={hideSelector}>
        {@html icon('close')}
      </button>
    {:else}
      <button class="show" on:click={showSelector}>
        {@html icon('arrows-v')}
        {i18n('Change author role')}
      </button>
    {/if}
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  div{
    background-color: #eee;
    @include radius;
    @include display-flex(row, stretch, center);
    margin: 0 0.5em;
  }
  .show{
    padding: 0.4em;
  }
  .hide{
    @include shy(0.8);
  }
</style>
