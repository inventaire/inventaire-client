<script lang="ts">
  import { intersection } from 'underscore'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import AuthorDisplay from './author_display.svelte'

  export let roleLabel, roleProperties, claims, authorsByUris

  $: claimsProperties = Object.keys(claims)
  $: hasRoleClaimsValues = isNonEmptyArray(intersection(roleProperties, claimsProperties))
</script>
{#if hasRoleClaimsValues}
  <div class="{roleLabel} authors-role">
    <span class="label">{I18n(roleLabel)}</span>
    <div class="authors">
      {#each roleProperties as prop}
        {#if claims[prop]}
          { @const hasManyClaimValues = claims[prop].length > 15}
          {#each claims[prop] as claimValue (claimValue)}
            <AuthorDisplay
              entity={authorsByUris[claimValue]}
              {claimValue}
              {hasManyClaimValues}
            />
          {/each}
        {/if}
      {/each}
    </div>
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .authors-role{
    @include display-flex(column, flex-start, flex-start, wrap);
  }
  .authors{
    @include display-flex(row, center, flex-start, wrap);
  }
  .label{
    color: $grey;
    font-size: 0.9rem;
    margin-block-end: 0.1em;
  }
</style>
