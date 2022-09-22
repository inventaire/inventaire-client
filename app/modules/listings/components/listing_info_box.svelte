<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { onChange } from '#lib/svelte/svelte'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import ListingEditor from '#listings/components/listing_editor.svelte'
  import Modal from '#components/modal.svelte'

  export let listing, isEditable

  let { name, description, creator: creatorId, visibility } = listing

  let visibilitySummary, visibilitySummaryIcon, visibilitySummaryLabel, showListEditorModal

  let username, userPicture, userListingsPathname
  const getCreator = async () => {
    ;({
      username,
      picture: userPicture,
      listingsPathname: userListingsPathname
    } = await app.request('get:user:data', creatorId))
  }

  const waitingForCreator = getCreator()

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
  <div class="header">
    <div class="first-row">
      <h2>{name}</h2>
      {#if isEditable}
        <div class="actions">
          <button
            class="tiny-button light-blue"
            on:click={() => showListEditorModal = true}
          >
            {@html icon('pencil')}
            {i18n('Edit list info')}
          </button>
        </div>
      {/if}
    </div>
    {#if description}
      <p>{description}</p>
    {/if}
  </div>
  <div class="creator-row">
    <div class="creator-info">
      <span class="label">{i18n('List creator')}</span>
      <a
        href={userListingsPathname}
        title={i18n('see_all_listings_by_user', { username })}
        on:click={loadInternalLink}
      >
        {#await waitingForCreator then}
          <img src={imgSrc(userPicture, 32)} alt="">
          <span class="username">{username}</span>
        {/await}
      </a>
    </div>
    {#if visibility}
      <div class="visibility">
        <span class="label">{i18n('Visible by')}</span>
        <span class="visibility-indicator">
          {@html icon(visibilitySummaryIcon)} {visibilitySummaryLabel}
        </span>
      </div>
    {/if}
  </div>
</div>

{#if showListEditorModal}
  <Modal
    on:closeModal={() => showListEditorModal = false}
  >
    <ListingEditor
      bind:listing
      on:listingEditorDone={() => showListEditorModal = false}
    />
  </Modal>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .listing-info{
    align-self: stretch;
    margin: 0.5em;
    margin-bottom: 1em;
    padding: 0.5em 1em 1em 1em;
    @include radius;
    background-color: $light-grey;
    max-width: 60em;
  }
  h2{
    margin-top: 0;
    font-weight: bold;
  }
  .first-row{
    @include display-flex(row, center, space-between);
    width: 100%;
  }
  .header{
    @include display-flex(column, baseline);
  }
  .isNotEditable{
    align-self: center;
    background-color: unset;
  }
  .creator-row{
    margin-top: 1em;
    @include display-flex(row, center, space-between);
  }
  .label{
    color: $label-grey;
    display: block;
  }
  .creator-info{
    a{
      display: block;
      padding: 0.5em;
      @include radius;
      @include bg-hover($light-grey);
    }
  }
  .username{
    font-weight: bold;
    @include sans-serif;
    margin-inline-start: 0.2em;
  }
  .actions{
    margin: 0.5em 0 0 auto;
  }
  button{
    margin-left: 1em;
    white-space: nowrap;
    line-height: 1.6em;
  }
  .visibility{
    padding: 0.2em;
    @include radius;
    text-align: end;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .listing-info{
      padding: 0.5em;
      margin: 1em 0;
    }
    .actions{
      margin: 0 0 1em auto;
    }
  }
  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .first-row{
      @include display-flex(column-reverse);
    }
    .actions{
      margin-bottom: 0;
    }
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .actions{
      margin-inline-start: 1em;
    }
  }
</style>
