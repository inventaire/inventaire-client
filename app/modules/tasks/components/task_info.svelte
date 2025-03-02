<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import type { SerializedContributor } from '#app/modules/users/lib/users'
  import Spinner from '#components/spinner.svelte'
  import type { Task } from '#server/types/task'
  import { I18n } from '#user/lib/i18n'
  import UserInfobox from '#users/components/user_infobox.svelte'
  import { getUsersByAccts } from '#users/users_data'

  export let task: Task

  const { reporters: reportersAccts, clue } = task

  let reporters: SerializedContributor[] = []
  const waitingForUsers = getUsersByAccts(reportersAccts)
    .then(res => reporters = Object.values(res))
</script>

{#await waitingForUsers}
  <Spinner center={true} />
{:then}
  <strong>{I18n('reporters')}</strong>
  <ul>
    {#each reporters as reporter}
      <li>
        <UserInfobox
          name={reporter.username}
          picture={reporter.picture}
          linkUrl={reporter.contributionsPathname}
          linkTitle={I18n('contributions_by', reporter)}
        />
      </li>
    {/each}
  </ul>
{/await}

{#if clue}
  <li>
    <strong>{I18n('clue')}</strong>
    <Link
      url={`/entity/isbn:${clue}`}
      text={clue}
    />
  </li>
{/if}
