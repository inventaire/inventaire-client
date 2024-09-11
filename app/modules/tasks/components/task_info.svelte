<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let reporter, clue
</script>
{#if reporter}
  <li>
    <strong>{i18n('reporter')}: </strong>
    <Link
      url={`/users/${reporter}/contributions`}
      text={reporter}
      title={`${I18n('username')}: ${reporter}`}
    />
  </li>
{/if}

{#if clue}
  <li>
    <strong>{i18n('clue')}: </strong>
    <Link
      url={`/entity/isbn:${clue}`}
      text={clue}
    />
  </li>
{/if}
