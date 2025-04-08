<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { currentRoute } from '#app/lib/location'
  import { isOpenedOutside, loadInternalLink } from '#app/lib/utils'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { i18n } from '#user/lib/i18n'

  export let item, showDistance = false

  const { pathname, user, currentTransaction } = item
  const { username, picture, pathname: userProfilePathname } = user
  const isPartOfCurrentPath = str => currentRoute().includes(str)

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }
</script>

<div class="mixed-box">
  {#if isPartOfCurrentPath(username)}
    <img class="profile-pic" alt="{username} avatar" src={imgSrc(picture, 48)} />
  {:else}
    <a
      href={userProfilePathname}
      on:click|stopPropagation={loadInternalLink}
    >
      <img class="profile-pic" alt="{username} avatar" src={imgSrc(picture, 48)} />
    </a>
  {/if}
  {#if isPartOfCurrentPath(item._id)}
    <div
      class="transaction-box"
      class:giving={currentTransaction.id === 'giving'}
      class:lending={currentTransaction.id === 'lending'}
      class:selling={currentTransaction.id === 'selling'}
      class:inventorying={currentTransaction.id === 'inventorying'}
      title={i18n(currentTransaction.labelPersonalized, user)}
    >
      {@html icon(currentTransaction.icon)}
    </div>
  {:else}
    <a
      class="transaction-box"
      class:giving={currentTransaction.id === 'giving'}
      class:lending={currentTransaction.id === 'lending'}
      class:selling={currentTransaction.id === 'selling'}
      class:inventorying={currentTransaction.id === 'inventorying'}
      href={pathname}
      title={i18n(currentTransaction.labelPersonalized, user)}
      on:click|stopPropagation={showItem}
    >
      {@html icon(currentTransaction.icon)}
    </a>
  {/if}
</div>
<div class="label-box">
  <div class="label">
    {#if isPartOfCurrentPath(item._id)}
      {@html i18n(currentTransaction.labelPersonalizedStrong, user)}
    {:else}
      <a
        href={pathname}
        on:click|stopPropagation={showItem}
      >
        {@html i18n(currentTransaction.labelPersonalizedStrong, user)}
      </a>
    {/if}
  </div>
  {#if showDistance && user.distanceFromMainUser}
    <span class="distance">{i18n('km_away', { distance: user.distanceFromMainUser })}</span>
  {/if}
</div>

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @use "#general/scss/utils";
  .mixed-box{
    @include display-flex(row);
  }
  .transaction-box{
    flex: 1 0 0;
    @include display-flex(column, center, center);
    :global(.fa){
      color: white;
      font-size: 1.5rem;
      // centering
      padding-inline-start: 0.2rem;
    }
  }
  .giving{
    background-color: $giving-color;
  }
  .lending{
    background-color: $lending-color;
  }
  .selling{
    background-color: $selling-color;
  }
  .inventorying{
    background-color: $inventorying-color;
  }
  .label-box{
    // wrapping combined with overflow:hidden hides .distance
    // if there isn't enough room for it
    @include display-flex(column, center, center, wrap);
    overflow: hidden;
    text-align: center;
    height: $user-box-heigth;
    background-color: #eee;
    width: 100%;
    .label{
      color: #444;
    }
    position: relative;
    .distance{
      font-size: 0.9em;
      line-height: 0.5em;
      color: #888;
    }
  }
  .profile-pic{
    height: $user-box-heigth;
  }
</style>
