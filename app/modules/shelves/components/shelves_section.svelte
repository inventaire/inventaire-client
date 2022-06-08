<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import { slide } from 'svelte/transition'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
import ShelfLi from '#shelves/components/shelf_li.svelte';

  export let username

  let showShelves = true

  let shelves, flash

  const waitForList = getUserId(username)
    .then(getShelvesByOwner)
    .then(res => shelves = res)
    .catch(err => flash = err)

  async function getUserId (username) {
    if (!username) return app.user.id
    return app.request('get:userId:from:username', username)
  }

  const toggleShelves = () => showShelves = !showShelves
</script>

<div class="wrapper">
  <button
    title={showShelves ? I18n('hide shelves') : I18n('show shelves')}
    aria-controls="shelves-list"
    on:click={toggleShelves}
  >
    <h3 class="subheader">{I18n('shelves')}</h3>
    {#if showShelves}
      {@html icon('chevron-down')}
    {:else}
      {@html icon('chevron-up')}
    {/if}
  </button>

  <div id="shelves-list">
    {#if showShelves}
      {#await waitForList}
        <Spinner />
      {:then}
        <ul transition:slide>
          {#each shelves as shelf}
            <ShelfLi {shelf} />
          {/each}
        </ul>
      {/await}
    {/if}
  </div>

  <pre>{JSON.stringify({ shelves }, null, 2)} (shelves_section.svelte:54)</pre>

  <Flash />
</div>
<!--
<div class="shelves-wrapper">
  <div id="shelvesHeader">
    <div class="shelves-subheader">
    </div>
  </div>

  <div id="toggleButtons">
  </div>
</div> -->

<style lang="scss">
  @import '#general/scss/utils';
  .wrapper{
    > button{
      width: 100%;
      @include display-flex(row, center, space-between);
    }
  }
  .subheader{
    font-size: 1rem;
    @include sans-serif;
  }
  // .shelves-wrapper{
  //   margin-top: 0.5em;
  //   background-color: $light-grey;
  // }
  // #toggleButtons:not(.hidden){
  //   background: $light-grey;
  //   display: flex;
  //   align-items: center;
  //   button{
  //     font-size: 1.5rem;
  //     flex: 1;
  //     @include text-hover($grey, $dark-grey);
  //     .fa{
  //       padding-right: 0.1em;
  //     }
  //   }
  // }
  // #shelvesHeader{
  //   cursor: pointer;
  //   @include display-flex(row, top, space-between);
  //   padding: 1em;
  //   /*Smaller screens*/
  //   @media screen and (max-width: $smaller-screen) {
  //     // balance the cross fold icon on the right
  //     padding: 1em 1em 1em 3.5em;
  //   }
  //   .subheader{
  //     margin-top: 0;
  //     margin-bottom: 0;
  //   }
  //   .shelves-subheader{
  //     flex: 1 0 0;
  //     padding-right: 0.8em;
  //     a{
  //       padding-top: 0.4em;
  //       padding-bottom: 0.4em;
  //     }
  //     @include display-flex(row, center, space-between);
  //   }
  //   /*Smaller screens*/
  //   @media screen and (max-width: $smaller-screen) {
  //     padding-right: 0.5em;
  //     .shelves-subheader{
  //       @include display-flex(column, center);
  //       margin-bottom: 0.4em;
  //     }
  //   }
  // }
</style>
