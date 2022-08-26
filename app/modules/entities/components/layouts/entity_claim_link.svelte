<script>
  import { externalIdsUrlFormatters } from '#entities/components/editor/lib/external_ids_url_formatters'
  import Link from '#lib/components/link.svelte'
  export let label, property, value

  const url = externalIdsUrlFormatters[property](value)
</script>

<Link {url} text={label} classNames="link" />
