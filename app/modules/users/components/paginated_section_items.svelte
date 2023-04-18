<script>
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { getPaginationParameters } from '#inventory/lib/paginated_items'
  import { screen } from '#lib/components/stores/screen'

  export let sectionRequestName, showDistance = false

  const pagination = getPaginationParameters({
    requestName: sectionRequestName,
    limit: 20,
    allowMore: true,
  })

  $: Component = $screen.isSmallerThan('$smaller-screen') ? ItemsTable : ItemsCascade
</script>

<PaginatedItems {Component} {showDistance} {pagination} />
