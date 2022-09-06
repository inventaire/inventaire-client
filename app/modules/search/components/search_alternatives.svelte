<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { slide } from 'svelte/transition'
  import { entitySectionsWithAlternatives, typesBySection } from '#search/lib/search_sections'
  import { looksLikeAnIsbn } from '#lib/isbn'
  import { createEventDispatcher } from 'svelte'

  export let selectedCategory, selectedSection, searchText, waiting

  const dispatch = createEventDispatcher()

  function showEntityCreate () {
    if (looksLikeAnIsbn(searchText)) {
      // If the edition entity for this ISBN really doesn't exist
      // it will redirect to the ISBN edition creation form
      app.execute('show:entity', searchText)
    } else {
      const type = typesBySection.entity[selectedSection]
      app.execute('show:entity:create', { label: searchText, type })
    }
    dispatch('closeLiveSearch')
  }

  $: showAlternatives = (searchText !== '' &&
    selectedCategory === 'entity' &&
    entitySectionsWithAlternatives.includes(selectedSection))
</script>

{#await waiting then}
  {#if showAlternatives}
    <div class="alternatives" transition:slide|local={{ delay: 1000 }}>
      <span class="label">{i18n("Can't find what you are searching?")}</span>
      <div class="propositions">
        <button on:click={showEntityCreate}>
          {@html icon('plus')}
          {I18n('create')}
        </button>
      </div>
    </div>
  {/if}
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .alternatives{
    background-color: #dadada;
    @include display-flex(row, center, center, wrap);
    padding: 0.2em 0.5em;
  }
  .label{
    color: $dark-grey;
  }
  .propositions{
    flex: 1 0 auto;
    @include display-flex(row, center, flex-end);
    button{
      line-height: 1.6rem;
      @include display-flex(row, center, center);
      padding: 0.2em 0;
      margin: 0.2em 0;
      min-width: 7em;
      text-align: center;
      @include tiny-button-color($dark-grey, white);
    }
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .alternatives{
      background-color: white;
    }
  }

  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .propositions{
      justify-content: center;
    }
  }

 /*Very Small screens*/
  @media screen and (max-height: 500px), (max-width: 500px){
    .alternatives{
      // A max-height is required for the transition:
      // it is set to be just a bit heigher than the height=auto would likely be,
      // but not too much, otherwise the transition starts from too far, and there is a delay
      max-height: 12em;
      @include transition(all, 0.5s);
    }
  }
</style>
