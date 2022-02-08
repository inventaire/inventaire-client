<script>
  import { I18n } from '#user/lib/i18n'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'
  export let type
  export let selected

  const customization = {
    listing: {
      title: 'visibility',
      // 'listing_description': 'select the visibility you would to apply to all selected books'
      options: app.user.listings(),
      defaultOption: 'private'
    },
    transaction: {
      title: 'transaction',
      // 'transaction_description': 'select the transaction mode you would to apply to all selected books'
      options: transactionsDataFactory(),
      defaultOption: 'inventorying'
    }
  }

  const title = customization[type].title
  const optionsData = Object.values(customization[type].options)
  selected = customization[type].defaultOption
</script>
<div class="itemCreation">
  <h4>{I18n(title)}</h4>
  <label for="{type}">{I18n(title + '_description')}</label>
  <div class="select-button-group">
    {#each optionsData as option}
      <button
        id="{option.id}"
        class="button {option.id}"
        on:click="{() => { selected = option.id }}"
        class:selected="{option.id === selected}"
        >
        <i class='fa fa-{option.icon}'></i>
        <span>{I18n(option.label)}</span>
      </button>
    {/each}
  </div>
</div>
<style lang="scss">
  @import '#inventory/scss/item_creation_commons';
  h4, label{
    text-align: center
  }
  .itemCreation{
    margin: 1em 0
  }
  label{
    font-size: 1em
  }
  .select-button-group{
    justify-content: center;
  }
</style>
