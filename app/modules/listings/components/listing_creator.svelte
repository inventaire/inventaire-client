<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  import { createListing } from '#modules/listings/lib/listings'
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'

  export let listing = {}

  const dispatch = createEventDispatcher()

  async function create () {
    const res = await createListing(listing)
    listing = res.listing
    app.user.trigger('listings:change', 'createListing')
    dispatch('newListing', listing)
  }
</script>

<form>
  <label>
    <span>{i18n('New list name')}</span>
    <input type="text" placeholder={i18n('ex: "Books for bird watchers"')} bind:value={listing.name}>
  </label>
  <button
    on:click={create}
    class="tiny-button light-blue"
    >
    {@html icon('plus')}
    {i18n('Create list')}
  </button>
</form>

<style lang="scss">
  @import '#general/scss/utils';
  form{
    @include display-flex(row, flex-end, flex-end);
    background-color: $off-white;
    padding: 0.5em;
    flex: 1 0 auto;
    margin-bottom: 1em
  }
  input{
    margin: 0;
    margin-left: 0.5em;
    flex: 1;
  }
  .tiny-button{
    margin-left: 0.5em;
    padding: 0.4em;
    white-space: nowrap;
  }
  label{
    @include display-flex(row, center, center);
    margin: 0 0.5em;
    white-space: nowrap;
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    form{
      padding: 1em 0.5em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    label{
      width: 100%
    }
  }
  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    label{
      display: block;
    }
    input{
      margin: 0;
    }
    button{
      margin-top: 1em;
    }
  }
</style>
