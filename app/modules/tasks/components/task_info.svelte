<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getUsersByIds } from '#users/users_data'

  export let task

  const { reporters: reportersIds, clue } = task

  let reporters
  const waitingForUsers = getUsersByIds(reportersIds)
    .then(res => reporters = Object.values(res))
</script>

{#await waitingForUsers}
  <Spinner center={true} />
{:then}
  <strong>{i18n('reporters')}: </strong>
  <ul>
    {#each reporters as reporter}
      <li class="creator-info">
        <a
          href={`/users/${reporter._id}/contributions`}
          title={I18n('contributions_by', reporter)}
          on:click={loadInternalLink}
        >
          <img src={imgSrc(reporter.picture, 32)} alt="" loading="lazy" />
          <span class="username">{reporter.username}</span>
        </a>
      </li>
    {/each}
  </ul>
{/await}

{#if clue}
  <li>
    <strong>{i18n('clue')}: </strong>
    <Link
      url={`/entity/isbn:${clue}`}
      text={clue}
    />
  </li>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .creator-info{
    a{
      display: block;
      padding: 0.3em 0;
      @include radius;
      @include bg-hover($light-grey);
    }
  }
  .username{
    font-weight: normal;
    @include sans-serif;
    margin-inline-start: 0.2em;
    margin-inline-end: 0.5em;
  }
</style>
