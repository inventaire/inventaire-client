<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { buildPath } from '#app/lib/location'
  import { loadInternalLink } from '#app/lib/utils'
  import { locallyCreatableEntitiesTypes } from '#entities/lib/editor/properties_per_type'
  import { I18n } from '#user/lib/i18n'

  export let section

  let createButtonHref

  const { parentUri, subEntityType, subEntityRelationProperty } = section
  if (parentUri && subEntityType && subEntityRelationProperty && locallyCreatableEntitiesTypes.includes(subEntityType)) {
    const claims = { [subEntityRelationProperty]: [ parentUri ] }
    createButtonHref = buildPath('/entity/new', { type: subEntityType, claims })
  }
</script>

<!-- TODO?: offer the possibility to search among existing entities, rather than creating a new one -->
{#if createButtonHref}
  <a href={createButtonHref} on:click={loadInternalLink} class="tiny-button">
    {@html icon('plus')}
    {I18n(`create a new ${subEntityType}`)}
  </a>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .tiny-button{
    display: inline-block;
    margin: 0.5em;
    align-self: flex-end;
  }
</style>
