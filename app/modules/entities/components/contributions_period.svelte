<script lang="ts">
  import { property } from 'underscore'
  import { API } from '#app/api/api'
  import app from '#app/app'
  import preq from '#app/lib/preq'
  import { isOpenedOutside } from '#app/lib/utils'
  import Spinner from '#general/components/spinner.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let title: string
  export let period: number = null

  let usersData
  let highest = 0

  const getContributionsData = async () => {
    const res = await preq.get(API.entities.usersContributionsCount(period))
    usersData = await addUsersData(res)
  }

  const addUsersData = async res => {
    let { contributions: contributionRows } = res
    if (contributionRows.length === 0) return []
    contributionRows = contributionRows.slice(0, 10)
    const usersIds = contributionRows.map(property('user'))
    const { users } = await preq.get(API.users.byIds(usersIds))
    // assuming contributions are already sorted
    highest = contributionRows[0].contributions
    contributionRows.forEach(row => row.user = users[row.user])
    return contributionRows
  }

  const showUserContributions = (e, user) => {
    if (!isOpenedOutside(e)) {
      app.execute('show:user:contributions', user._id)
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
    {#each usersData as userData}
      <div class="row">
        <div class="cell user" class:deleted={userData.user.deleted}>
          <a href="/users/{userData.user._id}/contributions" class="link" on:click={e => showUserContributions(e, userData.user)}>{userData.user.username}</a>
        </div>
        <div class="histogram">
          <div class="contributions">
            {userData.contributions}
          </div>
          <div class="bar" style:width="{userData.contributions * 100.0 / highest}px" />
        </div>
      </div>
    {:else}
      no contributions
    {/each}
  {/await}
</section>

<style lang="scss">
  @import "#general/scss/utils";
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
