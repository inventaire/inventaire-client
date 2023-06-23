<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { currentRoute } from '#lib/location'

  export let item, showDistance = false

  const { pathname, user, currentTransaction } = item
  const { username, picture, pathname: userProfilePathname } = user
  const isPartOfCurrentPath = str => currentRoute().includes(str)
</script>
<div class="mixedBox">
  {#if isPartOfCurrentPath(username)}
    <img class="profilePic" alt="{username} avatar" src={imgSrc(picture, 48)} />
  {:else}
    <a
      href={userProfilePathname}
      on:click|stopPropagation={loadInternalLink}
    >
      <img class="profilePic" alt="{username} avatar" src={imgSrc(picture, 48)} />
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
      on:click|stopPropagation={loadInternalLink}
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
        on:click|stopPropagation={loadInternalLink}
      >
        {@html i18n(currentTransaction.labelPersonalizedStrong, user)}
      </a>
    {/if}
  </div>
  {#if showDistance && user.distanceFromMainUser}
    <span class="distance">{i18n('km_away', { distance: user.distanceFromMainUser })}</span>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .mixedBox{
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
</style>
