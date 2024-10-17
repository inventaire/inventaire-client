<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import EntityImage from '#entities/components/entity_image.svelte'
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import Ebooks from '#entities/components/layouts/ebooks.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import ListingElementComment from '#modules/listings/components/listing_element_comment.svelte'
  import { I18n } from '#user/lib/i18n'

  export let element, entity, isCreatorMainUser

  const dispatch = createEventDispatcher()
  const { type, claims } = entity

  let flash
</script>

<div class="listing-element-show">
  <div class="entity-type-label">
    {I18n(type)}
  </div>
  <EntityTitle
    {entity}
    hasLinkTitle={true}
  />
  <div class="entity-info-row">
    {#if isNonEmptyPlainObject(entity.image)}
      <EntityImage
        {entity}
        size={256}
      />
    {/if}
    <div class="entity-infobox">
      <AuthorsInfo {claims} />
      <Infobox
        {claims}
        entityType={type}
        shortlistOnly={true}
      />
      <Ebooks {entity} />
    </div>
  </div>

  <Summary {entity} />

  {#if element.comment || isCreatorMainUser}
    <ListingElementComment
      {isCreatorMainUser}
      bind:element
      bind:flash
    />
  {/if}

  {#if isCreatorMainUser}
    <div class="buttons-wrapper">
      <button
        class="remove-button dark-grey"
        on:click={() => dispatch('removeElement', element)}
      >
        {@html icon('trash')}
        <span>{I18n('remove element')}</span>
      </button>
    </div>
  {/if}
</div>

<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .listing-element-show{
    min-width: 40em;
    /* Very small screens */
    @media screen and (width < $smaller-screen){
      min-width: 100%;
    }
  }
  .entity-type-label{
    color: $soft-grey;
    text-align: center;
  }
  .entity-info-row{
    display: flex;
    margin: 1em 0;
    :global(.image-div){
      margin-inline-end: 1em;
    }
  }
  .entity-infobox{
    margin: 0 1em;
    flex: 2;
  }
  button{
    min-width: 10rem;
    margin: 0 0.5em;
  }
  .remove-button{
    margin: 1em 0;
    padding: 0.4em 0.6em;
    @include shy(0.9);
    @include display-flex(row, center, center);
    :global(.fa){
      font-size: 1.1em;
    }
    &:hover, &:focus{
      border-radius: $global-radius;
      background-color: $danger-color;
      color: white;
    }
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .entity-info-row{
      @include display-flex(column, center);
      :global(.image-div){
        margin-block-end: 1em;
      }
    }
  }
</style>
