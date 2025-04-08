<script lang="ts">
  import { property } from 'underscore'
  import { API } from '#app/api/api'
  import preq from '#app/lib/preq'
  import { isOpenedOutside } from '#app/lib/utils'
  import Spinner from '#general/components/spinner.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { showUserContributionsFromAcct } from '#users/users'
  import { getUsersByAccts } from '#users/users_data'

  export let title: string
  export let period: number = null

  let usersData
  let highest = 0

  async function getContributionsData () {
    const res = await preq.get(API.entities.usersContributionsCount(period))
    usersData = await addContributors(res)
  }

  async function addContributors ({ contributions: contributionRows }) {
    if (contributionRows.length === 0) return []
    contributionRows = contributionRows.slice(0, 10)
    const usersAccts = contributionRows.map(property('user'))
    const users = await getUsersByAccts(usersAccts)
    // assuming contributions are already sorted
    highest = contributionRows[0].contributions
    contributionRows.forEach(row => row.contributor = users[row.user])
    return contributionRows
  }

  function showUserContributions (e, user) {
    if (!isOpenedOutside(e)) {
      showUserContributionsFromAcct(user.acct)
    }
  }
</script>

<section>
  <h2>{I18n(title)}</h2>
  {#await getContributionsData()}
    <p class="loading">Loading... <Spinner /></p>
  {:then}
    <div class="row">
      <div class="cell title">{i18n('user')}</div>
      <div class="cell title right">{i18n('contributions')}</div>
    </div>
    {#each usersData as { contributions, contributor }}
      <div class="row">
        <div class="cell user" class:deleted={contributor.deleted}>
          <a href={contributor.contributionsPathname} class="link" on:click={e => showUserContributions(e, contributor)}>{contributor.username || contributor.acct}</a>
        </div>
        <div class="histogram">
          <div class="contributions">
            {contributions}
          </div>
          <div class="bar" style:width="{contributions * 100.0 / highest}px"></div>
        </div>
      </div>
    {:else}
      no contributions
    {/each}
  {/await}
</section>

<style lang="scss">
  @use "#general/scss/utils";
  section{
    min-inline-size: 20em;
    max-inline-size: 50em;
    background-color: white;
    padding: 1em;
    margin: 0.5em;
  }
  .contributions{
    padding: 0 0.5em;
    position: absolute;
    flex: 2 0 auto;
  }
  .row{
    display: flex;
    flex-direction: row;
  }
  .histogram{
    min-inline-size: 100px;
    margin: 0.1em 0.2em;
  }
  .bar{
    background-color: $light-grey;
    block-size: 100%;
  }
  .cell{
    flex: 1 0 auto;
    background-color: $light-grey;
    padding: 0 0.5em;
    margin: 0.1em 0;
  }
  .deleted{
    color: red;
  }
  .right{
    text-align: end;
  }
  .title{
    background-color: white;
  }
</style>
