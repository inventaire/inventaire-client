<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import VisibilitySelector from '#components/visibility_selector.svelte'
  import Dropdown from '#components/dropdown.svelte'
  import { getCorrespondingListing, visibilityIconByCorrespondingListing } from '#general/lib/visibility'
  import { clone, debounce, isEqual } from 'underscore'
  import { onChange } from '#lib/svelte'

  export let item, flash

  let listing, iconName
  $: {
    listing = getCorrespondingListing(item.visibility)
    iconName = visibilityIconByCorrespondingListing[listing]
  }

  let { visibility } = item

  async function save () {
    await app.request('items:update', {
      items: [ item ],
      attribute: 'visibility',
      value: visibility,
    })
  }

  const lazySave = debounce(save, 1000)

  async function udpateAndSave () {
    if (isEqual(item.visibility, visibility)) return
    const previousVisibility = clone(visibility)
    item.visibility = visibility
    try {
      lazySave()
    } catch (err) {
      flash = err
      item.visibility = visibility = previousVisibility
    }
  }

  function clickOnContentShouldCloseDropdown (e) {
    // Close dropdown when clicking on the save button
    // but not on the checkboxes
    return e.target.className.includes('save')
  }

  $: onChange(visibility, udpateAndSave)
</script>

<div class="item-card-box">
  <Dropdown
    align="right"
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
        bind:visibility
        maxHeight=10.5em
        />
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
</style>
