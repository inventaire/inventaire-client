<script>
  import RelativeEntitiesList from '#entities/components/layouts/relative_entities_list.svelte'
  import { i18n } from '#user/lib/i18n'
  import { getReverseClaimLabel, getRelativeEntitiesProperties, getRelativeEntitiesClaimProperties } from '#entities/components/lib/relative_entities_helpers.js'

  export let entity, mainProperty

  const { type, label } = entity
</script>

<div class="relatives-lists">
  <RelativeEntitiesList
    {entity}
    property={[ 'wdt:P2679', 'wdt:P2680' ]}
    label={i18n('editions_prefaced_or_postfaced_by_author', { name: label })}
  />
  {#each getRelativeEntitiesProperties(type, mainProperty) as property}
    <RelativeEntitiesList
      {entity}
      {property}
      label={getReverseClaimLabel({ property, entity })}
    />
  {/each}
  {#each getRelativeEntitiesClaimProperties(type) as claimProperty}
    <RelativeEntitiesList
      {entity}
      label={i18n(claimProperty, { name: label })}
      claims={entity.claims[claimProperty]}
    />
  {/each}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .relatives-lists{
      @include display-flex(row, baseline, flex-start, wrap);
      $margin: 1rem;
      // Hide the extra margin on each wrapped line
      margin-inline-end: -$margin;
      :global(.relative-entities-list.not-empty){
        flex: 1 0 40%;
        margin-inline-end: $margin;
        margin-block-end: $margin;
      }
    }
  }
</style>
