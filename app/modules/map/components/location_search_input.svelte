<script>
  import getActionKey from '#lib/get_action_key'

  export let map

  let results

  let resultList

  let searchQuery = ''

  function searchLocation () {
    fetch(
      `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(
        searchQuery
      )}&format=json`
    )
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          results = data
        }
      })
      .catch(error => {
        console.error('Error searching location:', error)
      })
  }

  function setView (index) {
    let mapZoom = 13
    const latLng = [
      parseFloat(results[index].lat),
      parseFloat(results[index].lon),
    ]
    map.setView(latLng, mapZoom)
    L.marker(latLng).addTo(map)
    resultList.remove()
  }

  function searchKey (e) {
    if (getActionKey(e) === 'enter') {
      searchLocation()
    }
  }

</script>

<div id="locationSearchInput">
  <input
    type="text"
    bind:value={searchQuery}
    on:keydown={searchKey}
    placeholder="Search for a location"
  />
  <button on:click={searchLocation}>Search</button>
  {#if results}
    <ul bind:this={resultList}>
      {#each results as result, i}
        <!-- {console.log(result)} -->
        <li on:click={() => setView(i)} on:keypress={() => setView(i)}>{result.display_name}</li>
      {/each}
    </ul>
  {/if}
</div>

<style>
    #locationSearchInput{
      position: absolute;
      top: 0;
      right: 0;
      z-index: 1000;
      padding: 10px;
      width: 300px;
    }

    #locationSearchInput button{
      background-color: blue;
      color: white;
      font-weight: bold;
    }

    #locationSearchInput ul{
      background-color: aliceblue;
      padding: 5px;
    }

    #locationSearchInput li{
        padding-bottom: 5px;
        border-bottom: 2px solid black;
    }
    #locationSearchInput li:hover{
        cursor: pointer;
    }
</style>
