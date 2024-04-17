<script lang="ts">
  import { screen } from '#app/lib/components/stores/screen'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { getPaginationParameters } from '#inventory/lib/paginated_items'

  export let sectionRequestName, showDistance = false

  const pagination = getPaginationParameters({
    requestName: sectionRequestName,
    limit: 20,
    allowMore: true,
  })
</script>

<PaginatedItems
  display={$screen.isSmallerThan('$smaller-screen') ? 'table' : 'cascade'}
  {showDistance}
  {pagination}
/>
