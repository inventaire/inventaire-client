<script>
    import getActionKey from "#lib/get_action_key";

    export let map;

    let searchQuery = "";

    function searchLocation() {
        fetch(
            `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(
                searchQuery
            )}&format=json`
        )
            .then((response) => response.json())
            .then((data) => {
                if (data.length > 0) {
                    let mapZoom = 13;
                    const result = data[0];
                    const latLng = [
                        parseFloat(result.lat),
                        parseFloat(result.lon),
                    ];
                    map.setView(latLng, mapZoom);
                    L.marker(latLng).addTo(map);
                }
            })
            .catch((error) => {
                console.error("Error searching location:", error);
            });
    }

    function searchKey(e) {
        if (getActionKey(e) === "enter") {
            searchLocation();
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
</div>

<style>
    #locationSearchInput {
        position: absolute;
        top: 0;
        right: 0;
        z-index: 1000;
        padding: 10px;
    }

    #locationSearchInput button {
        background-color: blue;
        color: white;
        font-weight: bold;
    }
</style>
