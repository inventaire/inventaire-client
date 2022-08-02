<!-- Needed to let app/modules/general/lib/modal.js access onModalExit  -->
<svelte:options accessors/>

<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getSeriePathname } from '#inventory/components/lib/item_show_helpers'
  import { serializeItem } from '#inventory/lib/items'
  import { onMount } from 'svelte'
  import AuthorsPreviewLists from '#inventory/components/authors_preview_lists.svelte'
  import ItemShelves from '#inventory/components/item_shelves.svelte'
  import ItemShowData from '#inventory/components/item_show_data.svelte'
  import ItemActiveTransactions from '#inventory/components/item_active_transactions.svelte'
  import Flash from '#lib/components/flash.svelte'
  import app from '#app/app'

  export let item, user, entity, works, authorsByProperty, fallback
  export const onModalExit = fallback

  const seriePathname = getSeriePathname(works)

  item.user = user
  const serializedItem = serializeItem(item)
  const { mainUserIsOwner } = serializedItem

  const entityIsEdition = entity.type === 'edition'

  const { snapshot } = item

  onMount(() => app.execute('modal:open', 'large'))

  let flash
</script>

<div class="item-show">
  <h3>{I18n('book')}</h3>

  <div class="wrapper">
    <div class="one">
      {#if entityIsEdition}
        <span class="section-label">{I18n('edition')}</span>
      {:else}
        <span class="section-label">{I18n('work')}</span>
      {/if}
      <a class="showEntity {entity.type}" href={entity.pathname}>
        {#if snapshot['entity:image']}
          <img class="entity-image" src={imgSrc(snapshot['entity:image'], 400)} alt={snapshot['entity:title']}>
        {/if}
        <p class="title" lang={snapshot['entity:lang']} >{snapshot['entity:title']}</p>
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
          <a class="work showEntity" href={work.pathname}>
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

      {#if snapshot['entity:series']}
        {#if seriePathname}
          <p class="series-preview">
            <span class="section-label">{I18n('serie')}</span>
            <a class="showEntity" href={seriePathname}>
              <span class="related-entity-label">{snapshot['entity:series']}</span>
            </a>
          </p>
        {/if}
      {/if}
    </div>

    <div class="two">
      <ItemShowData item={serializedItem} {user} bind:flash />
      <ItemShelves {serializedItem} />
      {#if app.user.loggedIn}
        <ItemActiveTransactions item={serializedItem} bind:flash />
      {/if}
      <Flash bind:state={flash} />
      {#if mainUserIsOwner}
        <button class="remove remove-button dark-grey">
          {I18n('delete')}
          {@html icon('trash-o')}
        </button>
      {/if}
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .item-show{
    padding: 0 1em;
    position: relative;
  }
  h3{
    @include layout-type-label;
  }
  .two{
    margin: 0;
    max-width: 36em;
    min-height: 350px;
  }
  a.edition, a.work, .series-preview a{
    margin: 0.2em 0;
    @include bg-hover-svelte(#f3f3f3);
  }
  a.edition, a.work{
    @include display-flex(column, center, center);
    margin-bottom: 2em;
  }
  .series-preview{
    margin-top: 1em;
    .related-entity-label{
      padding: 0.5em;
    }
  }
  // Also target .section-label in authors preview lists
  .item-show :global(.section-label){
    color: $grey;
    display: block;
  }
  .identifier{
    font-size: 0.7em;
    color: $grey;
  }
  .entity-image{
    margin-bottom: 0.5em;
  }
  .title{
    font-size: 1.1em;
  }
  .title, .authors, .scenarists, .illustrators, .colorists, .related-entity-label{
    font-weight: bold;
  }
  .remove-button{
    float: right;
    margin: 1em 0;
    padding: 0.2em 1em;
    @include shy(0.9);
    @include display-flex(row, center, center);

    :global(.fa){
      font-size: 1.1em;
    }
    &:hover, &:focus {
      @include tiny-button-padding;
      border-radius: $global-radius;
      background-color: $danger-color;
      padding: 0.2em 1em;
      color: white;
      span{
        padding-left: 0.4em;
      }
    }
  }
  .preciseEdition{
    display: block;
    margin: 0 auto;
    text-align: center;
    margin: 1em 0;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .wrapper{
      @include display-flex(column, stretch, center);
    }
    .one{
      margin-bottom: 1em;
    }
    .title{
      padding: 0.5em;
    }
  }

  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .wrapper{
      @include display-flex(row, flex-start, center);
    }
    .one{
      flex: 1 0 0;
      max-width: 15em;
      margin-right: 1em;
    }
    .two{
      flex: 2 0 0;
      margin: 0 auto;
      padding-bottom: 1em;
    }
  }
</style>
