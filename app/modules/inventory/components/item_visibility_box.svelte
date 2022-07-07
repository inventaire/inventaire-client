<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import VisibilitySelector from '#components/visibility_selector.svelte'
  import Dropdown from '#components/dropdown.svelte'
  import { getCorrespondingListing, visibilityIconByCorrespondingListing } from '#general/lib/visibility'
  import { clone } from 'underscore'

  export let item, flash

  let selectedVisibility = clone(item.visibility)

  let listing, iconName
  $: {
    listing = getCorrespondingListing(item.visibility)
    iconName = visibilityIconByCorrespondingListing[listing]
  }

  async function save () {
    const previousVisibility = clone(item.visibility)
    item.visibility = selectedVisibility
    try {
      await app.request('items:update', {
        items: [ item ],
        attribute: 'visibility',
        value: selectedVisibility,
      })
    } catch (err) {
      flash = err
      item.visibility = selectedVisibility = previousVisibility
    }
  }

  function clickOnContentShouldCloseDropdown (e) {
    // Close dropdown when clicking on the save button
    // but not on the checkboxes
    return e.target.className.includes('save')
  }
</script>

<div class="item-card-box">
  <Dropdown
    buttonTitle={i18n('Select who can see this item')}
    clickOnContentShouldCloseDropdown={clickOnContentShouldCloseDropdown}
    >
    <!-- Not using a dynamic class to avoid `no-unused-selector` warnings -->
    <!-- See See https://github.com/sveltejs/svelte/issues/1594 -->
    <div
      slot="button-inner"
      class:private={listing === 'private'}
      class:network={listing === 'network'}
      class:public={listing === 'public'}
      >
      {@html icon(iconName)}
      {@html icon('caret-down')}
    </div>
    <div slot="dropdown-content">
      <!-- maxHeight is set to display only partially the first overflowing option
           to give the hint to scroll down for more -->
      <VisibilitySelector
        bind:visibility={selectedVisibility}
        maxHeight=10.5em
        />
      <button on:click={save} class="save tiny-button success">
        {@html icon('check')}
        {I18n('save')}
      </button>
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#inventory/scss/item_card_box';
  [slot="button-inner"]{
    &.private{
      background-color: $private-color;
      color: white;
    }
    &.network{
      background-color: $network-color;
      color: white;
    }
    &.public{
      background-color: $public-color;
    }
  }
  [slot="dropdown-content"]{
    @include display-flex(column, stretch);
  }
  .save{
    margin: 0.5em auto;
  }
</style>
