<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'

  export let listing, isEditable

  let { name, description, creator: creatorId, visibility } = listing
  let creator = {}

  let visibilitySummary, visibilitySummaryIcon, visibilitySummaryLabel

  const getCreatorUsername = async () => {
    if (isEditable) return creator = app.user.toJSON()
    creator = await getUserById(creatorId)
  }

  const getUserById = id => preq.get(app.API.users.byIds([ id ])).then(({ users }) => users[id])

  const waitingForCreator = getCreatorUsername()

  const showEditor = async () => {
    const { default: ListingEditor } = await import('#modules/listings/components/listing_editor.svelte')
    app.execute('modal:open')
    const component = app.layout.showChildComponent('modal', ListingEditor, {
      props: {
        listing,
      }
    })
    component.$on('listingUpdated', event => {
      listing = event.detail.listing
    })
    // todo: garbage collect event listener with onDestroy
  }

  const updateVisibilitySummary = () => {
    visibility = listing.visibility
    visibilitySummary = getVisibilitySummary(visibility)
    visibilitySummaryIcon = visibilitySummariesData[visibilitySummary].icon
    visibilitySummaryLabel = i18n(getVisibilitySummaryLabel(visibility))
  }

  $: name = listing.name
  $: description = listing.description
  $: onChange(listing, updateVisibilitySummary)
</script>

<div
  class="listing-info"
  class:isNotEditable={!isEditable}
>
  <div class="data">
    <h3>{name}</h3>
    <div class="visibility {visibilitySummary}" title="{visibilitySummaryLabel}">
      {@html icon(visibilitySummaryIcon)} {visibilitySummaryLabel}
    </div>
    {#if description}
      <p>{description}</p>
    {/if}
    {#await waitingForCreator then}
      <div class="creatorRow">
        <label for='listCreator'>
          {i18n('creator')}:
        </label>
        <a
          id="listCreator"
          href="/inventory/{creator.username}"
          on:click={loadInternalLink}
        >
          {creator.username}
        </a>
      </div>
    {/await}
  </div>
  {#if isEditable}
    <div class="actions">
      <button
        class="tiny-button light-blue"
        on:click={showEditor}
      >
        {@html icon('pencil')}
        {i18n('Edit list info')}
      </button>
    </div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .listing-info{
    align-self: center;
    margin: 0.5em;
    margin-bottom: 1em;
    padding: 1em;
    @include radius;
    @include display-flex(row);
    background-color: $light-grey;
    max-width: 60em;
  }
  .isNotEditable{
    align-self: center;
    background-color: unset;
  }
  .creatorRow{
    @include display-flex(row);
  }
  .actions{
    margin: 1em;
    margin-left: auto;
  }
  button{
    // padding: 0.5em;
    white-space: nowrap;
    line-height: 1.6em;
    // width: 10em;
  }
  a:hover{
    text-decoration: underline;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .listing-info{
      @include display-flex(column);
      padding: 0.5em;
      margin: 1em 0;
    }
  }
</style>
