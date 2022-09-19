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
    <span>{i18n('List name')}</span>
    <input type="text" placeholder={i18n('ex: "Books for bird watchers"')} bind:value={listing.name}>
  </label>
  <button
    on:click={create}
    class="tiny-button light-blue"
    >
    {@html icon('plus')}
    {i18n('Create a new list')}
  </button>
</form>

<style lang="scss">
  @import '#general/scss/utils';
  form{
    @include display-flex(row, flex-end, flex-end);
    flex: 1 0 auto;
    margin-bottom: 1em
  }
  label{
    // @include display-flex(row, center, center);
    // margin: 0 0.5em;
    // white-space: nowrap;
  }
  input{
    max-width: 30em;
    margin: 0;
    flex: 1;
  }
  .tiny-button{
    margin-left: 0.5em;
    padding: 0.4em;
    white-space: nowrap;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    label{
      display: block;
    }
    button{
      margin-top: 1em;
    }
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    label{
      @include display-flex(row, center, center);
      margin: 0 0.5em;
      white-space: nowrap;
    }
    input{
      margin-left: 0.5em;
    }
  }
</style>
