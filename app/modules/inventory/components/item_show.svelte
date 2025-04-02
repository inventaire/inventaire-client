<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { isOpenedOutside, loadInternalLink } from '#app/lib/utils'
  import { commands } from '#app/radio'
  import Spinner from '#components/spinner.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import AuthorsPreviewLists from '#inventory/components/authors_preview_lists.svelte'
  import ItemActiveTransactions from '#inventory/components/item_active_transactions.svelte'
  import ItemShelves from '#inventory/components/item_shelves.svelte'
  import ItemShowData from '#inventory/components/item_show_data.svelte'
  import { getItemEntityData } from '#inventory/components/lib/item_show_helpers'
  import { serializeItem } from '#inventory/lib/items'
  import { I18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'
  import { serializeUser } from '#users/lib/users'
  import { deleteItems } from '../lib/item_actions'

  export let item, user

  item.user = user = serializeUser(user)
  item = serializeItem(item)
  const { mainUserIsOwner } = item

  app.navigate(item.pathname, { preventScrollTop: true })

  let entity, works, series, authorsByProperty, entityIsEdition, flash
  const waitingForEntity = getItemEntityData(item.entity)
    .then(res => {
      ;({ entity, works, series, authorsByProperty } = res)
      entityIsEdition = entity.type === 'edition'
    })
    .catch(err => flash = err)

  const { snapshot } = item

  function destroyItem () {
    return deleteItems({
      items: [ item ],
      next: () => {
        // Force a refresh of the inventory, so that the deleted item doesn't appear
        commands.execute('show:inventory:main:user')
      },
    })
  }

  const dispatch = createEventDispatcher()

  function loadInternalLinkAndClose (e) {
    if (isOpenedOutside(e)) return
    loadInternalLink(e)
    dispatch('navigate')
  }
</script>

<div class="item-show">
  <h3>{I18n('book')}</h3>

  <div class="wrapper">
    <!-- TODO: extract .one to a subcomponent -->
    <div class="one">
      {#await waitingForEntity}
        <Spinner />
      {:then}
        {#if entityIsEdition}
          <span class="section-label">{I18n('edition')}</span>
        {:else}
          <span class="section-label">{I18n('work')}</span>
        {/if}
        <a
          class:edition={entity.type === 'edition'}
          class:work={entity.type === 'work'}
          href={entity.pathname}
          on:click={loadInternalLinkAndClose}
        >
          {#if snapshot['entity:image']}
            <img class="entity-image" src={imgSrc(snapshot['entity:image'], 400)} alt={snapshot['entity:title']} />
          {/if}
          <p class="title" lang={snapshot['entity:lang']}>{snapshot['entity:title']}</p>
          {#if snapshot['entity:subtitle']}
            <p class="subtitle" lang={snapshot['entity:lang']}>{snapshot['entity:subtitle']}</p>
          {/if}
          {#if entityIsEdition}
            {#if entity.claims['wdt:P212']}
              <span class="identifier">ISBN: {entity.claims['wdt:P212']}</span>
            {/if}
          {/if}
        </a>

        {#if entityIsEdition}
          <span class="section-label">
            {#if works.length > 1}{I18n('works')}{:else}{I18n('work')}{/if}
          </span>
          {#each works as work}
            <a class="work" href={work.pathname} on:click={loadInternalLinkAndClose}>
              <span class="related-entity-label" lang={work.labelLang}>{work.label}</span>
            </a>
          {/each}
        {:else}
          <!-- {#if mainUserIsOwner}
          <a class="preciseEdition tiny-button light-blue bold" title={I18n('precise the edition')}>
            {@html icon('question-circle')}
            {i18n('which edition?')}
          </a>
        {/if} -->
        {/if}

        <AuthorsPreviewLists {authorsByProperty} />

        {#if series.length >= 1}
          <span class="section-label">
            {#if series.length > 1}{I18n('series')}{:else}{I18n('serie')}{/if}
          </span>
          {#each series as serie}
            <a class="serie" href={serie.pathname} on:click={loadInternalLinkAndClose}>
              <span class="related-entity-label" lang={serie.labelLang}>{serie.label}</span>
            </a>
          {/each}
        {/if}

        <!-- TODO: add publishers and collections -->
        <!-- TODO: add a link to work editor: "🖉 Add an author, genre, or subject to that work"  -->
        <!-- TODO: add a link to edition editor: "🖉 Add a translator, foreword/afterword author, book cover, etc to that specific edition"  -->
      {/await}
    </div>

    <div class="two">
      <ItemShowData bind:item {user} bind:flash />
      <ItemShelves bind:serializedItem={item} bind:flash />
      {#if mainUser}
        <ItemActiveTransactions {item} bind:flash />
      {/if}
      <Flash bind:state={flash} />
      {#if entity}
        <div class="summary">
          <Summary {entity} showLabel={true} />
        </div>
      {/if}
      {#if mainUserIsOwner}
        <button
          class="remove remove-button dark-grey"
          on:click={destroyItem}
        >
          {I18n('delete')}
          {@html icon('trash-o')}
        </button>
      {/if}
    </div>
  </div>
</div>

<!-- TODO: display edition summary when available -->

<style lang="scss">
  @import "#general/scss/utils";
  .item-show{
    position: relative;
    min-width: min(90vw, 60em);
  }
  h3{
    @include layout-type-label;
  }
  .one{
    text-wrap: balance;
  }
  .two{
    margin: 0;
    max-width: 36em;
    min-height: 350px;
  }
  .edition, .work, .serie{
    @include display-flex(column, center, center);
    text-align: center;
    min-height: 3em;
    margin: 0.2em 0;
    @include bg-hover-svelte(#f3f3f3);
  }
  // Also target .section-label in authors preview lists
  .item-show :global(.section-label){
    color: $grey;
    display: block;
  }
  .identifier{
    font-size: 0.7em;
    color: $grey;
    font-family: sans-serif;
  }
  .entity-image{
    margin-block-end: 0.5em;
  }
  .title{
    font-size: 1.1em;
    max-height: 8em;
    overflow: auto;
  }
  .title, .related-entity-label{
    font-weight: bold;
  }
  .remove-button{
    float: inline-end;
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
  .summary{
    margin-block-start: 1rem;
    :global(.summary.has-summary){
      padding: 0.5em 1em;
    }
    :global(.label){
      color: $grey;
    }
  }
  // .preciseEdition{
  //   display: block;
  //   text-align: center;
  //   margin: 1em 0;
  // }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .item-show{
      padding: 0 0.5em;
    }
    .wrapper{
      @include display-flex(column, stretch, center);
    }
    .one{
      margin-block-end: 1em;
    }
    .title{
      padding: 0.5em;
    }
  }

  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .item-show{
      padding: 0 1em;
    }
    .wrapper{
      @include display-flex(row, flex-start, center);
    }
    .one{
      flex: 1 0 0;
      max-width: 15em;
      margin-inline-end: 1em;
    }
    .two{
      flex: 2 0 0;
      margin: 0 auto;
      padding-block-end: 1em;
    }
  }
</style>
