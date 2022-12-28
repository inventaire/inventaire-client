<script>
  import { I18n } from '#user/lib/i18n'

  export let category, name, label, selectedCategory, selectedSection, included

  function select () {
    selectedCategory = category
    selectedSection = name
  }

  $: selected = selectedCategory === category && selectedSection === name
  $: included = selectedCategory === category && selectedSection === 'all' && name !== 'subject'
</script>

<button
  data-category="entity"
  data-name={name}
  class:selected
  class:included
  aria-controls="searchResults"
  on:click={select}
>
  {I18n(label)}
</button>

<style lang="scss">
  @import '#general/scss/utils';
  button{
    font-weight: normal;
    border-radius: 0;
    min-width: $search-section-width;
    padding: 0.5em 0.2em;
    background-color: #f3f3f3;
    transition: color 0.3s ease, background-color 0.3s ease;
    &:hover{
      background-color: $grey;
      color: white;
    }
  }
  .included{
    background-color: #ddd;
  }
  .selected{
    background-color: $light-blue;
    color: white;
  }

  /*Very Small screens*/
  @media screen and (max-width: calc(5 * $search-section-width)) {
    button{
      flex: 1 0 0;
    }
  }
</style>
