<script>
  import { getBasicInfoByUri } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import Link from '#lib/components/link.svelte'

  export let uri,
    label,
    basicInfo,
    title = ''

  let waitingForEntityBasicInfo

  $: {
    if (uri && !label) {
      waitingForEntityBasicInfo = getBasicInfoByUri(uri)
        .then(setInfo)
    }
  }

  function setInfo (data) {
    basicInfo = data
    label = data.label
  }
</script>

{#await waitingForEntityBasicInfo}
  <Spinner />
{:then}
  {#if label}
    <Link
      url={`/entity/${uri}`}
      text={label}
      title={title}
      dark={true}
    />
  {/if}
{/await}
