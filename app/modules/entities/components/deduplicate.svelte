<!-- TODO: refactor as a JS module -->
<script>
  import { isNonEmptyArray } from 'lib/boolean_tests'
  import { getEntitiesByUris } from '../lib/entities'
  import { getAuthorWorks } from '../lib/types/author'
  import { addWorksImagesAndAuthors } from '../lib/types/work'
  import DeduplicateAuthors from './deduplicate_authors.svelte'
  import DeduplicateWorks from './deduplicate_works.svelte'

  let state, name, worksPromise

  export let uris

  if (!isNonEmptyArray(uris)) {
    uris = app.request('querystring:get', 'uris')?.split('|')
  }

  if (isNonEmptyArray(uris)) {
    loadFromUris(uris)
  } else {
    state = 'deduplicate:authors'
    name = app.request('querystring:get', 'name')
  }

  async function getAuthorWorksWithImagesAndCoauthors (author) {
    const works = await getAuthorWorks(author)
    await addWorksImagesAndAuthors(works)
    works.forEach(work => {
      work.coauthors = work.authors.filter(coauthor => coauthor.uri !== author.uri)
    })
    return works
  }

  async function loadFromUris () {
    const entities = await getEntitiesByUris(uris)
    // Guess type from first entity
    const { type } = entities[0]
    if (type === 'human' && entities.length === 1) {
      const author = entities[0]
      worksPromise = getAuthorWorksWithImagesAndCoauthors(author)
      state = 'deduplicate:works'
      return
    }

    // If we haven't returned at this point, it is a non handled case
    throw new Error(`case not handled yet: ${type}`)
  }
</script>

<div class="content">
	{#if state === 'deduplicate:authors'}
		<DeduplicateAuthors {name} />
	{:else if state === 'deduplicate:works'}
		<DeduplicateWorks {worksPromise} />
	{/if}
</div>
