<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let item, showDistance = true

  const { pathname, user, currentTransaction } = item
</script>

<div class="mixedBox">
  <a href="{user.pathname}" class="showUser">
    <img class="profilePic" alt="{user.username} avatar" src="{imgSrc(user.picture, 48)}">
  </a>
  <a class="itemShow" href="{pathname}">
    <div class="transactionBox {currentTransaction.id}">
      {@html icon(currentTransaction.icon)}
    </div>
  </a>
</div>
<div class="labelBox {currentTransaction.id}">
  <a class="itemShow label" href="{pathname}">
    {@html i18n(currentTransaction.labelPersonalized, user)}
  </a>
  {#if showDistance && user.distance}
    <span class="distance">{i18n('km_away', user)}</span>
  {/if}
</div>
