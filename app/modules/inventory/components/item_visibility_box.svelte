<script lang="ts">
  import { debounce, isEqual } from 'underscore'
  import type { FlashState } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import Dropdown from '#components/dropdown.svelte'
  import { getVisibilitySummary, getVisibilitySummaryLabel, iconByVisibilitySummary } from '#general/lib/visibility'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { updateItems } from '#inventory/lib/item_actions'
  import type { SerializedItem } from '#inventory/lib/items'
  import { i18n, I18n } from '#user/lib/i18n'

  export let item: SerializedItem
  export let flash: FlashState = null
  export let large = false
  export let dropdownWidthReferenceEl = null

  let visibility = item.visibility
  let savedVisibility = visibility
  $: item.visibility = visibility

  async function save () {
    try {
      if (isEqual(savedVisibility, visibility)) return
      await updateItems({
        items: [ item ],
        attribute: 'visibility',
        value: visibility,
      })
      savedVisibility = visibility
    } catch (err) {
      // Ignore duplicated request errors
      // as that means the server is at the desired state
      if (err.statusCode === 429) return
      // Restore saved value
      visibility = savedVisibility
      flash = err
    }
  }

  const lazySave = debounce(save, 1000)

  let visibilitySummary, iconName, iconLabel
  function onVisibilityChange () {
    lazySave()
    visibilitySummary = getVisibilitySummary(visibility)
    iconName = iconByVisibilitySummary[visibilitySummary]
    iconLabel = getVisibilitySummaryLabel(visibility)
    item.visibilitySummary = visibilitySummary
    item.visibilitySummaryIconName = iconName
  }

  $: onChange(visibility, onVisibilityChange)

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
    {clickOnContentShouldCloseDropdown}
    {dropdownWidthReferenceEl}
    alignDropdownWidthOnButton={large}
  >
    <!-- Not using a dynamic class to avoid `no-unused-selector` warnings -->
    <!-- See See https://github.com/sveltejs/svelte/issues/1594 -->
    <div
      slot="button-inner"
      class:private={visibilitySummary === 'private'}
      class:network={visibilitySummary === 'network'}
      class:public={visibilitySummary === 'public'}
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
        maxHeight="15em"
      />
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#inventory/scss/item_card_box";
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
