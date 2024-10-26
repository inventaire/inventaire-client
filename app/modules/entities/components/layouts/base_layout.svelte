<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import EntityLayoutActionsMenu from '#entities/components/layouts/entity_layout_actions_menu.svelte'
  import { entityTypeNameBySingularType } from '#entities/lib/types/entities_types'
  import { i18n, I18n } from '#user/lib/i18n'
  import EmbeddedWelcome from '#welcome/components/embedded_welcome.svelte'

  export let entity
  export let flash = null
  export let showEntityEditButtons = true
  export let typeLabel = entity.type

  const { uri, wdUri, invUri } = entity

  const labelKey = entityTypeNameBySingularType[typeLabel] || 'subject'

  function copyToClipBoard (str) {
    navigator.clipboard.writeText(str)
  }
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header">
      <h2 class="type-label">{I18n(labelKey)}</h2>
    </div>
    <EntityLayoutActionsMenu
      bind:entity
      {showEntityEditButtons}
    />
  </div>
  <div class="entity-wrapper">
    <slot name="entity" />
  </div>
  <Flash state={flash} />
  <div class="entity-data-wrapper">
    <p class="uri">
      {I18n(typeLabel)}
      -
      <button
        on:click={() => copyToClipBoard(uri)}
        class="uri classic-link"
        title={i18n('Copy URI to clipboard')}
      >
        {uri}
      </button>

      {#if wdUri && wdUri !== uri}
        -
        <button
          on:click={() => copyToClipBoard(wdUri)}
          class="uri classic-link"
          title={i18n('Copy URI to clipboard')}
        >
          {wdUri}
        </button>
      {/if}
      {#if invUri && invUri !== uri}
        -
        <button
          on:click={() => copyToClipBoard(invUri)}
          class="uri classic-link"
          title={i18n('Copy URI to clipboard')}
        >
          {invUri}
        </button>
      {/if}
    </p>
  </div>
</div>

<EmbeddedWelcome />

<style lang="scss">
  @import "#general/scss/utils";
  .layout{
    @include display-flex(column, stretch, center);
    margin: 0 auto;
    max-inline-size: 84em;
    background-color: white;
  }
  .type-label{
    color: $grey;
    font-size: 1.1rem;
    @include sans-serif;
  }
  .header-wrapper{
    display: flex;
    margin: 1em 0;
  }
  .header{
    @include display-flex(row, center, center);
    inline-size: 100%;
  }
  .entity-wrapper{
    @include display-flex(column, flex-start);
  }
  .entity-data-wrapper{
    @include display-flex(column, center);
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .layout{
      padding: 0 1em;
    }
    .header-wrapper{
      margin-inline-start: 1.2em;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .layout{
      padding: 0 0.5em;
    }
    .header-wrapper{
      @include display-flex(row, center, space-between);
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
  /* Very Small screens */
  @media screen and (width < $very-small-screen){
    .layout{
      padding: 0 0.5em;
    }
  }
</style>
