<script>
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import GroupMarker from '#map/components/group_marker.svelte'
  import LeafletMap from '#map/components/leaflet_map.svelte'
  import Marker from '#map/components/marker.svelte'
  import PositionRequired from '#map/components/position_required.svelte'
  import UserMarkerAlt from '#map/components/user_marker_alt.svelte'
  import { getBbox } from '#map/lib/map'
  import { i18n, I18n } from '#user/lib/i18n'
  import { user } from '#user/user_store'
  import { getGroupsByPosition, getUsersByPosition } from '#users/components/lib/public_users_nav_helpers'
  import PublicItemsNearby from '#users/components/public_items_nearby.svelte'
  import UsersHomeSectionList from '#users/components/users_home_section_list.svelte'

  export let filter

  const showUsers = filter !== 'groups'
  const showGroups = filter !== 'users'

  let usersById = {}, groupsById = {}
  let map, bbox, mapViewLatLng, mapZoom, flash

  const getByPosition = async (name, bbox) => {
    try {
      if (name === 'users') {
        usersById = await getUsersByPosition({ bbox })
        usersInBounds = Object.values(usersById)
      } else if (name === 'groups') {
        groupsById = await getGroupsByPosition({ bbox })
        groupsInBounds = Object.values(groupsById)
      }
    } catch (err) {
      flash = err
    }
  }

  const waiters = {}
  function fetchAndShowUsersAndGroupsOnMap () {
    if (!map) return
    if (mapIsTooZoomedOut()) return
    bbox = getBbox(map)
    if (!bbox) return

    if (showUsers) {
      waiters.users = getByPosition('users', bbox)
    }

    if (showGroups) {
      waiters.groups = getByPosition('groups', bbox)
    }
  }

  function initMapViewFromMainUserPosition () {
    mapViewLatLng = $user.position
  }

  function mapIsTooZoomedOut () {
    if (mapZoom >= 10) return false
    if (!usersInBounds || !groupsInBounds) return false
    const displayedElementsCount = usersInBounds.length + groupsInBounds.length
    return displayedElementsCount > 20
  }

  let zoomInToDisplayMore = false
  function updateZoomStatus () {
    zoomInToDisplayMore = mapIsTooZoomedOut()
  }

  let usersInBounds, groupsInBounds

  $: onChange(map, fetchAndShowUsersAndGroupsOnMap)
  $: onChange($user.position, initMapViewFromMainUserPosition)
  $: onChange(mapZoom, usersInBounds, groupsInBounds, updateZoomStatus)
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
          {#if usersInBounds}
            <UsersHomeSectionList
              docs={usersInBounds}
              type="users"
              hideList={zoomInToDisplayMore}
              hideListMessage={i18n('Zoom-in to display more')} />
          {/if}
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
          {#if groupsInBounds}
            <UsersHomeSectionList
              docs={groupsInBounds}
              type="groups"
              hideList={zoomInToDisplayMore}
              hideListMessage={i18n('Zoom-in to display more')} />
          {/if}
        </div>
      {/if}
    </div>

    <div id="mapContainer">
      {#if mapViewLatLng}
        <LeafletMap
          bind:map
          view={mapViewLatLng}
          bind:zoom={mapZoom}
          cluster={true}
          on:moveend={fetchAndShowUsersAndGroupsOnMap}
        >
          {#if usersInBounds && !zoomInToDisplayMore}
            {#each usersInBounds as user (user._id)}
              <Marker latLng={user.position}>
                <UserMarkerAlt doc={user} />
              </Marker>
            {/each}
          {/if}

          {#if groupsInBounds && !zoomInToDisplayMore}
            {#each groupsInBounds as group (group._id)}
              <Marker latLng={group.position}>
                <GroupMarker doc={group} />
              </Marker>
            {/each}
          {/if}

          {#if zoomInToDisplayMore}
            <div class="zoom-in-overlay">
              <p>{i18n('Zoom-in to display more')}</p>
            </div>
          {/if}
        </LeafletMap>
      {/if}
    </div>
  </div>

  <!-- TODO: use bbox to update displayed items accordingly -->
  <PublicItemsNearby {bbox} />
{:else}
  <PositionRequired />
{/if}

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  @import "#users/scss/users_home_section_navs";

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
    position: relative;
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

  .zoom-in-overlay{
    background-color: rgba($dark-grey, 0.5);
    @include position(absolute, 0, 0, 0, 0);
    // Above map but below controls
    z-index: 400;
    @include display-flex(column, center, center);
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
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

  /* Large screens */
  @media screen and (min-width: $small-screen){
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
