<script lang="ts">
  import app from '#app/app'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import Modal from '#components/modal.svelte'
  import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
  import ListingEditor from '#listings/components/listing_editor.svelte'
  import { i18n } from '#user/lib/i18n'

  export let listing, isEditable

  let { name, description, creator: creatorId, visibility } = listing

  let visibilitySummary, visibilitySummaryIcon, visibilitySummaryLabel, showListEditorModal

  let username, userPicture, userListingsPathname
  const getCreator = async () => {
    ;({
      username,
      picture: userPicture,
      listingsPathname: userListingsPathname,
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

<div class="listing-info">
  <div class="header">
    <div class="first-row">
      <h2>{name}</h2>
      {#if isEditable}
        <Dropdown
          align="right"
          buttonTitle={i18n('Show actions')}
          clickOnContentShouldCloseDropdown={true}
        >
          <div slot="button-inner">
            {@html icon('cog')}
          </div>
          <ul slot="dropdown-content">
            <li>
              <button on:click={() => showListEditorModal = true}
              >
                {@html icon('pencil')}
                {i18n('Edit list info')}
              </button>
            </li>
          </ul>
        </Dropdown>
      {/if}
    </div>
    {#if description}
      <p>{@html description}</p>
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
          <img src={imgSrc(userPicture, 32)} alt="" loading="lazy" />
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
  <Modal on:closeModal={() => showListEditorModal = false}
  >
    <ListingEditor
      bind:listing
      on:listingEditorDone={() => showListEditorModal = false}
    />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .listing-info{
    align-self: stretch;
    margin: 0.5em;
    margin-block-end: 1em;
    padding: 0.5em 1em 1em;
    @include radius;
    background-color: $light-grey;
  }
  h2{
    margin-block-start: 0;
    font-weight: bold;
  }
  .first-row{
    @include display-flex(row, center, space-between);
    width: 100%;
  }
  .header{
    @include display-flex(column, baseline);
  }
  .creator-row{
    margin-block-start: 1em;
    @include display-flex(row, center, space-between);
  }
  .label{
    color: $label-grey;
    display: block;
  }
  .creator-info{
    a{
      display: block;
      padding: 0.3em 0;
      @include radius;
      @include bg-hover($light-grey);
    }
  }
  .username{
    font-weight: bold;
    @include sans-serif;
    margin-inline-start: 0.2em;
  }
  [slot="button-inner"]{
    @include tiny-button($grey);
    padding: 0.5em;
  }
  [slot="dropdown-content"]{
    min-width: min(10em, 100vw);
    @include shy-border;
    background-color: white;
    @include radius;
    position: relative;
    :global(li){
      @include display-flex(row, stretch, flex-start);
      &:not(:last-child){
        margin-block-end: 0.2em;
      }
    }
    :global(button){
      flex: 1;
      @include display-flex(row, center, flex-start);
      min-block-size: 3em;
      @include bg-hover(white, 10%);
      padding: 0 1em;
      text-align: start;
    }
    :global(.fa){
      margin-inline-end: 0.5rem;
    }
  }
  .visibility{
    padding: 0.2em;
    @include radius;
    text-align: end;
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .listing-info{
      padding: 1em;
      margin: 0;
    }
    [slot="button-inner"]{
      padding: 0.3em;
    }
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .first-row{
      @include display-flex(column-reverse);
    }
  }
</style>
