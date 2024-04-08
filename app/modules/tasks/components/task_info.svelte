<script lang="ts">
  import { i18n } from '#user/lib/i18n'

  export let task

  $: ({ reporter, clue } = task)
</script>

{#if reporter}
  <li>
    <strong>{i18n('reporter')}: </strong>
    <a href="/users/{reporter}/contributions" class="link">{reporter}</a>
  </li>
{/if}

{#if clue}
  <li>
    <strong>{i18n('clue')}: </strong>
    <a href="/entity/isbn:{clue}" class="link">{clue}</a>
  </li>
{/if}
