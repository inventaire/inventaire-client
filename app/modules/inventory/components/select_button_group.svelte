<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'
  export let type
  export let selected

  const titles = {
    listing: 'visibility',
    transaction: 'transaction'
  }

  const title = titles[type]

  const optionsTypes = {
    transaction: transactionsDataFactory(),
    listing: app.user.listings()
  }
  const optionsData = Object.values(optionsTypes[type])

  const defaultOptions = {
    transaction: 'inventorying',
    listing: 'private'
  }
  selected = defaultOptions[type]
</script>

<label for="{type}">{I18n(title)}</label>
<div class="select-button-group {type}">
  {#each optionsData as option}
    <button
      class="button {option.id}"
      on:click="{() => { selected = option.id }}"
      class:selected="{option.id === selected}"
      >
      {@html icon(option.icon)} <span>{I18n(option.label)}</span>
    </button>
  {/each}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .selected{background-color: $light-blue}
  label{font-size: 1em;}
</style>
