<script>
  import { I18n } from 'modules/user/lib/i18n'
  import properties from 'modules/entities/lib/properties'
  import ClaimEditor from './claim_editor.svelte'
  export let entity
</script>

{#each Object.entries(entity.claims) as [ property, propertyClaims ]}
  {#if properties[property]}
    <div class="editor-section">
      <h3 class="editor-section-header">{I18n(property)}</h3>
      {#each propertyClaims as value}
        <ClaimEditor {entity} {property} {value} />
      {/each}
    </div>
  {/if}
{/each}

<style lang="scss">
  @import 'app/modules/entities/scss/entity_editors_commons';
  .editor-section{
    @include display-flex(row);
  }
  .editor-section-header{
    width: 9em;
  }
</style>
