<script>
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import preq from '#lib/preq'
  import PositionRequired from '#map/components/position_required.svelte'
  import { drawMap } from '#map/lib/draw'
  import { getBbox, getLatLng, getLeaflet, isValidBbox, showOnMap, showUserOnMap } from '#map/lib/map'
  import { solvePosition } from '#network/lib/nearby_layouts'
  import { I18n } from '#user/lib/i18n'
  import { user } from '#user/user_store'
  import { isNotMainUser } from '#users/components/lib/navs_helpers'
  import UsersHomeSectionList from '#users/components/users_home_section_list.svelte'
  import { pluck } from 'underscore'

  export let filter

  const showUsers = filter !== 'groups'
  const showGroups = filter !== 'users'

  let users = [], groups = []
  let map, bounds, flash

  const getByPosition = async (name, bbox) => {
    if (!isValidBbox(bbox)) throw new Error(`invalid bbox: ${bbox}`)
    let { [name]: docs } = await preq.get(app.API[name].searchByPosition(bbox))
    if (name === 'users') {
      const knownIds = new Set(pluck(users, '_id'))
      docs = docs
        .filter(isNotMainUser)
        .filter(doc => !knownIds.has(doc._id))
      users = users.concat(docs)
    } else if (name === 'groups') {
      const knownIds = new Set(pluck(groups, '_id'))
      docs = docs.filter(doc => !knownIds.has(doc._id))
      groups = groups.concat(docs)
    }
  }

  function fetchAndShowUsersAndGroupsOnMap () {
    const displayedElementsCount = users.length + groups.length
    if (map._zoom < 10 && displayedElementsCount > 20) return
    const bbox = getBbox(map)
    if (!bbox) return
    bounds = map.getBounds()

    if (showUsers) {
      showUserOnMap(map, app.user)
      showByPosition('users', bbox)
    }

    if (showGroups) {
      showByPosition('groups', bbox)
    }
  }

  const waiters = {}
  async function showByPosition (name, bbox) {
    waiters[name] = getByPosition(name, bbox)
    await waiters[name]
    const docs = name === 'users' ? users : groups
    showOnMap(name, map, docs)
  }

  const mapContainerId = 'mapContainer'
  Promise.all([
    solvePosition(),
    getLeaflet(),
  ])
  .then(([ coords ]) => {
    const { lat, lng, zoom } = coords
    map = drawMap({
      containerId: mapContainerId,
      latLng: [ lat, lng ],
      zoom,
      cluster: true
    })
    fetchAndShowUsersAndGroupsOnMap()
    map.on('moveend', fetchAndShowUsersAndGroupsOnMap)
  })
  .catch(err => flash = err)

  const docIsInBounds = bounds => doc => {
    const latLng = getLatLng(doc)
    return bounds.contains(latLng)
  }

  $: usersInBounds = users.filter(docIsInBounds(bounds))
  $: groupsInBounds = groups.filter(docIsInBounds(bounds))
</script>

{#if $user.position != null}
  <div class="map-lists-wrapper">
    <div class="lists">
      {#if showUsers}
        <div class="list-wrapper">
          <div class="list-header">
            <h2 class="list-label">{I18n('users')}</h2>
            {#await waiters.users}
              <div class="usersLoading"><Spinner /></div>
            {/await}
          </div>
          {#await waiters.users then}
            <UsersHomeSectionList docs={usersInBounds} type="users" />
          {/await}
        </div>
      {/if}

      {#if showGroups}
        <div class="list-wrapper">
          <div class="list-header">
            <h2 class="list-label">{I18n('groups')}</h2>
            {#await waiters.groups}
              <div class="groupsLoading"><Spinner /></div>
            {/await}
          </div>
          {#await waiters.groups then}
            <UsersHomeSectionList docs={groupsInBounds} type="groups" />
          {/await}
        </div>
      {/if}
    </div>

    <!-- Avoid using just 'map' as id as that sets a global variable that might cause confusion -->
    <!-- See https://www.tjvantoll.com/2012/07/19/dom-element-references-as-global-variables/ -->
    <div id={mapContainerId}></div>
  </div>
{:else}
  <PositionRequired />
{/if}

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  @import '#users/scss/users_home_section_navs';

  .list-header{
    @include display-flex(row, center, space-between);
  }

  .usersLoading, .groupsLoading{
    margin-left: 1em;
    opacity: 0.6;
  }

  .map-lists-wrapper{
    display: flex;
  }

  #mapContainer{
    z-index: 0;
    @include display-flex(row, center, center);
    background-color: $off-white;
    :global(.items-count), :global(.group-admin-badge), :global(.members-count){
      position: absolute;
      background-color: white;
      color: $dark-grey;
      line-height: 0;
      min-width: 1em;
    }
    :global(.items-count), :global(.members-count){
      top: 0;
      right: 0;
      text-align: center;
      padding: 0.2em 0;
      border-bottom-left-radius: $global-radius;
      @include transition;
    }
    :global(.group-admin-badge){
      top: 0;
      left: 0;
      // Somehow centers the icon vertically
      line-height: 0;
      border-bottom-right-radius: $global-radius;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .lists{
      flex-direction: column;
    }
    .map-lists-wrapper{
      flex-direction: column;
    }
    #mapContainer{
      order: -1;
      height: 20em;
      max-height: 50vh;
    }
  }

  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .map-lists-wrapper{
      > div{
        flex: 1 0 0;
      }
    }
    #mapContainer{
      margin-left: 0.6em;
      height: $map-large-screen-heigth;
    }
  }
</style>
