<script>
  import { i18n } from '#user/lib/i18n'

  export let task

  $: ({ reporter, clue } = task)
</script>

<li>
  <strong>{i18n('reporter')}: </strong>
  <a href="/users/{reporter}/contributions" class="link">{reporter}</a>

</li>
<li>
  <strong>{i18n('clue')}: </strong>
  <a href="/entity/isbn:{clue}" class="link">{clue}</a>
</li>
