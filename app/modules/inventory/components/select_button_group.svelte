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
      defaultOption: 'private',
      description: 'Who can see it?',
    },
    transaction: {
      title: 'transaction',
      // 'transaction_description': 'select the transaction mode you would to apply to all selected books'
      options: transactionsDataFactory(),
      defaultOption: 'inventorying',
      description: "I have it and it's available for",
    }
  }

  const title = customization[type].title
  const description = customization[type].description
  const optionsData = Object.values(customization[type].options)
  selected = customization[type].defaultOption
</script>
<div class="itemCreation">
  <label for="{type}-selector">
    <p class="title">{I18n(title)}</p>
    <p class="description">{I18n(description)}</p>
  </label>
  <div id="{type}-selector" class="select-button-group" role="menu">
    {#each optionsData as option}
      <button
        id="{option.id}"
        class="button {option.id}"
        on:click="{() => { selected = option.id }}"
        class:selected="{option.id === selected}"
        role="menuitem"
        >
        <i class='fa fa-{option.icon}'></i>
        <span>{I18n(option.label)}</span>
      </button>
    {/each}
  </div>
</div>
<style lang="scss">
  @import '#inventory/scss/item_creation_commons';
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
  .itemCreation{
    margin: 1em 0
  }
  .select-button-group{
    justify-content: center;
  }
</style>
