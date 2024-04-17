<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import ClaimInfobox from './claim_infobox.svelte'

  export let entity, relatedEntities

  const { claims, subtitle, pathname } = entity
</script>
<div class="entity-list-compact">
  <div class="date">
    <ClaimInfobox
      values={claims['wdt:P577']}
      prop="wdt:P577"
      omitLabel={true}
    />
  </div>

  <div class="title">
    <Link
      url={pathname}
      text={claims['wdt:P1476']}
      dark={true}
    />
    {#if subtitle}
      <span class="subtitle">{subtitle}</span>
    {/if}
  </div>
  <!-- TODO: display publisher by fetching more related entities
  (see function fetchRelatedEntities)
  {#if $screen.isLargerThan('$small-screen')}
    <div class="publisher">
      <ClaimInfobox
        values={claims['wdt:P123']}
        prop="wdt:P123"
        omitLabel={true}
      />
    </div>
  {/if}
  -->
  <div class="authors">
    <ClaimInfobox
      values={claims['wdt:P50']}
      prop="wdt:P50"
      omitLabel={true}
      entitiesByUris={relatedEntities}
    />
  </div>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/entity_list_compact";
</style>
