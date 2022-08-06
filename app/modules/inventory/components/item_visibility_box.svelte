<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import Dropdown from '#components/dropdown.svelte'
  import { getCorrespondingListing, getIconLabel, visibilityIconByCorrespondingListing } from '#general/lib/visibility'
  import { debounce, isEqual } from 'underscore'
  import { onChange } from '#lib/svelte/svelte'
  import { getDocStore } from '#lib/svelte/mono_document_stores'

  export let item, flash, large = false, widthReferenceEl

  const itemStore = getDocStore({ category: 'items', doc: item })

  // Do not make it reactive to let udpateAndSave determine if it changed
  let visibility = $itemStore.visibility

  async function save () {
    try {
      await app.request('items:update', {
        items: [ item ],
        attribute: 'visibility',
        value: visibility,
      })
    } catch (err) {
      flash = err
    }
  }

  const lazySave = debounce(save, 1000)

  async function udpateAndSave () {
    if (isEqual($itemStore.visibility, visibility)) return
    lazySave()
  }

  $: onChange(visibility, udpateAndSave)

  const reconcileWithStore = () => visibility = $itemStore.visibility
  $: onChange($itemStore.visibility, reconcileWithStore)

  let listing, iconName, iconLabel
  $: {
    listing = getCorrespondingListing(visibility)
    iconName = visibilityIconByCorrespondingListing[listing]
    iconLabel = getIconLabel(visibility)
    item.listing = listing
    item.listingIconName = iconName
  }

  function clickOnContentShouldCloseDropdown (e) {
    // Close dropdown when clicking on the save button
    // but not on the checkboxes
    return e.target.className.includes('save')
  }
</script>

<div class="item-card-box item-visibility-box" class:large>
  <Dropdown
    align="right"
    buttonTitle={i18n('Select who can see this item')}
    clickOnContentShouldCloseDropdown={clickOnContentShouldCloseDropdown}
    {widthReferenceEl}
    alignButtonAndDropdownWidth={large}
    >
    <!-- Not using a dynamic class to avoid `no-unused-selector` warnings -->
    <!-- See See https://github.com/sveltejs/svelte/issues/1594 -->
    <div
      slot="button-inner"
      class:private={listing === 'private'}
      class:network={listing === 'network'}
      class:public={listing === 'public'}
      >
      <div class="icon">
        {@html icon(iconName)}
        {#if !large}{@html icon('caret-down')}{/if}
      </div>
      {#if large}
        <div class="rest">
          <span>{I18n(iconLabel)}</span>
          {@html icon('caret-down')}
        </div>
      {/if}
    </div>
    <div slot="dropdown-content">
      <!-- maxHeight is set to display only partially the first overflowing option
           to give the hint to scroll down for more -->
      <VisibilitySelector
        bind:visibility
        maxHeight=15em
        />
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#inventory/scss/item_card_box';
  [slot="button-inner"]{
    &.private{
      .icon{
        background-color: $private-color;
        color: white;
      }
    }
    &.network{
      .icon{
        background-color: $network-color;
        color: white;
      }
    }
    &.public{
      .icon{
        background-color: $public-color;
      }
    }
  }
  [slot="dropdown-content"]{
    @include display-flex(column, stretch);
  }
</style>
