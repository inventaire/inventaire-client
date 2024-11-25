<script lang="ts">
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import Ebooks from '#entities/components/layouts/ebooks.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { authorsProps } from '#entities/components/lib/claims_helpers'
  import type { SerializedEntity } from '#entities/lib/entities'

  export let entity: SerializedEntity
  export let shortlistOnly = null
  export let hasLinkTitle = false

  const { type } = entity
  $: claims = entity.claims
</script>

<EntityTitle
  {entity}
  {hasLinkTitle}
/>
<AuthorsInfo {claims} />
<Infobox
  {claims}
  entityType={type}
  omittedProperties={authorsProps}
  {shortlistOnly}
/>
<Ebooks {entity} />
<Summary {entity} />
