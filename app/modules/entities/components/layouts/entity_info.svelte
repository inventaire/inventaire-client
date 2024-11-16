<script lang="ts">
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import Ebooks from '#entities/components/layouts/ebooks.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { authorsProps } from '#entities/components/lib/claims_helpers'

  export let entity, shortlistOnly, hasLinkTitle

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
