<script lang="ts">
  import { screen } from '#app/lib/components/stores/screen'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { getPaginationParameters } from '#inventory/lib/paginated_items'
  import type { ItemsPageRequestFn } from '#inventory/lib/queries'

  export let sectionRequest: ItemsPageRequestFn
  export let showDistance = false

  const pagination = getPaginationParameters({
    request: sectionRequest,
    limit: 20,
    allowMore: true,
  })
</script>

<PaginatedItems
  display={$screen.isSmallerThan('$smaller-screen') ? 'table' : 'cascade'}
  {showDistance}
  {pagination}
/>
