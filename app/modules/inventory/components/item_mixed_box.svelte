<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let item, showDistance = false

  const { pathname, user, currentTransaction } = item
</script>

<div class="mixedBox">
  <a href={user.pathname} on:click|stopPropagation={loadInternalLink}>
    <img class="profilePic" alt="{user.username} avatar" src="{imgSrc(user.picture, 48)}">
  </a>
  <a
    class="transaction-box"
    class:giving={currentTransaction.id === 'giving'}
    class:lending={currentTransaction.id === 'lending'}
    class:selling={currentTransaction.id === 'selling'}
    class:inventorying={currentTransaction.id === 'inventorying'}
    href={pathname}
    on:click|stopPropagation={loadInternalLink}
    >
    {@html icon(currentTransaction.icon)}
  </a>
</div>
<div class="label-box">
  <a
    href={pathname}
    class="label"
    on:click|stopPropagation={loadInternalLink}
  >
    {@html i18n(currentTransaction.labelPersonalizedStrong, user)}
  </a>
  {#if showDistance && user.distanceFromMainUser}
    <span class="distance">{i18n('km_away', { distance: user.distanceFromMainUser })}</span>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .mixedBox{
    @include display-flex(row);
  }
  .transaction-box{
    flex: 1 0 0;
    color: white;
    @include display-flex(column, center, center);
    :global(.fa){
      font-size: 1.5rem;
      // centering
      padding-left: 0.2rem;
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
