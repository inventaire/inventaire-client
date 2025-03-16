<script context="module" lang="ts">
  import type { EntityUri, InvClaimValue } from '#server/types/entity'
  // Cache entities labels, assuming those labels are stable: typically for language entities and such
  const cache = {}
</script>

<script lang="ts">
  import { getEntityLabel } from '#entities/lib/entities'

  // Accept InvClaimValue to work around type casting not being possible within Svelte parent components
  export let uri: EntityUri | InvClaimValue

  const labelPromise = cache[uri] ??= getEntityLabel(uri as EntityUri)
</script>

<span class="entity-label">{#await labelPromise then { label }}{label}{/await}</span>
