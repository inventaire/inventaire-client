<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
  import Flash from '#lib/components/flash.svelte'
  import LeafletMap from '#map/components/leaflet_map.svelte'
  import { getPositionFromNavigator } from '#map/lib/navigator_position'
  import Marker from '#map/components/marker.svelte'
  import Spinner from '#components/spinner.svelte'
  import { createEventDispatcher } from 'svelte'
  import { wait } from '#lib/promises'
  import { truncateDecimals } from '#map/lib/geo'
  import LocationSearchInput from '#map/components/location_search_input.svelte'

  export let type
  export let position
  export let savePosition

  let title, context, tip, map, marker, flash, metersRadius, waitingForPosition

  if (type === 'user') {
    title = 'edit your position'
    context = 'position_privacy_context'
    tip = 'position_privacy_tip'
    metersRadius = 200
  } else if (type === 'group') {
    title = "edit the group's position"
    context = 'group_position_context'
    metersRadius = 20
  }

  const dispatch = createEventDispatcher()

  let mapLatLng = position

  function findPositionFromGeolocation () {
    waitingForPosition = getPositionFromNavigator()
      .then(({ lat, lng }) => mapLatLng = [ lat, lng ])
      .catch(err => flash = err)
  }

  function getMapCenterLatLng () {
    const { lat, lng } = map.getCenter()
    return [ lat, lng ].map(truncateDecimals)
  }

  function updateMarker () {
    if (!(map && marker)) return
    marker.setLatLng(getMapCenterLatLng())
  }

  let removing
  async function removePosition () {
    try {
      removing = savePosition(null)
      await removing
      flash = { type: 'success', message: I18n('removed') }
      await wait(800)
      dispatch('positionPickerDone')
    } catch (err) {
      flash = err
    }
  }

  let validating
  async function validatePosition () {
    try {
      validating = savePosition(getMapCenterLatLng())
      await validating
      flash = { type: 'success', message: I18n('saved') }
      await wait(800)
      dispatch('positionPickerDone')
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="position-picker">
  <h3>{I18n(title)}</h3>
  <p class="context">{i18n(context)}</p>
  {#if !mapLatLng}
    <div class="position-inputs">
      <div>
        <LocationSearchInput
          inputLabel={i18n('Search for a location')}
          inputPlaceholder={i18n("What's the nearest city?")}
          on:selectLocation={e => mapLatLng = e.detail.latLng}
        />
      </div>
      <div class="separator">{i18n('or')}</div>
      <div>
        <button on:click={findPositionFromGeolocation} class="light-blue-button">
          {@html icon('crosshairs')}
          {i18n('Geolocate')}
        </button>
      </div>
    </div>
  {/if}
  {#if mapLatLng}
    <div class="map-container">
      <LeafletMap
        bind:map
        view={mapLatLng}
        showLocationSearchInput={true}
        on:move={updateMarker}
      >
        <Marker
          bind:marker
          latLng={mapLatLng}
          standalone={true}
          markerType="circle"
          {metersRadius}
        />
      </LeafletMap>
    </div>
  {:else}
    {#await waitingForPosition}
      <div class="waiting-for-position">
        <Spinner />
        {i18n('Waiting for browser geolocation')}
      </div>
    {/await}
  {/if}
  {#if mapLatLng && tip}
    <p class="tip">{@html icon('info-circle')}{i18n(tip)}</p>
  {/if}
  <div class="bottom">
    {#if position}
      <button
        on:click={removePosition}
        class="button bold radius grey"
        disabled={removing || validating}
      >
        {#await removing}
          <Spinner />
        {:then}
          {@html icon('trash')}
        {/await}
        {I18n('delete position')}
      </button>
    {/if}
    {#if mapLatLng}
      <button
        on:click={validatePosition}
        class="button bold radius success"
        disabled={removing || validating}
      >
        {#await validating}
          <Spinner />
        {:then}
          {@html icon('check')}
        {/await}
        {I18n('save position')}
      </button>
    {/if}
  </div>
  <Flash state={flash} />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .position-picker{
    text-align: center;
  }
  .context{
    padding: 0.5em 0.5em 0.2em;
  }
  .tip{
    background-color: $lighter-grey;
    padding: 0.2em 0.5em 0.5em;
  }
  .bottom{
    margin-block-start: 1em;
  }
  .map-container{
    background-color: $lighter-grey;
    height: 40em;
  }
  .position-inputs{
    @include display-flex(row, center, center);
    margin: 1em;
    div:not(.separator){
      margin: 1em;
    }
  }
  .waiting-for-position{
    padding: 2em;
  }
  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    .map-container{
      max-height: 50vh;
    }
    .position-inputs{
      flex-direction: column;
    }
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    .position-picker{
      padding: 1em;
    }
    .map-container{
      max-height: 70vh;
    }
  }
</style>
