# Troubleshooting
For when you're looking for a clue of how to solve a problem

## In the browser console
### "foo" is read-only
Some [ESM import](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Instructions/import) is being overriden somewhere, which is not allowed (esm import defines variables as constants)

### foo is undefined / foo is not a function
#### option 1: foo is an imported variable
The decaffeination messed with a lot of import/exports: the typical error is that a module might export an object by default:
```js
// some_module.js
export default {
  foo: 123
}
```
and that the consumer might be trying to access `foo` with destructuring assignment:
```js
import { foo } from './some_module'
// => error: foo is undefined
```
This fails because the [ESM import](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Instructions/import) is different from destructuring assignment.
This can normally be fixed in two ways. Either change the export:
```js
// some_module.js
export const foo = 123
```
or change the import:
```js
import someModule from './some_module'
const { foo } = someModule
// => error: foo is undefined
```

### TypeError: fooModuleName.default is undefined
It might be that there is no `export default` in the module you are trying to import, so `import fooModuleName from './foo_module_name` will fail. Possible solution: `import * as fooModuleName from './foo_module_name`

### TypeError: foo(...).then / foo(...).catch is not a function
Calling the function `foo` should have returned a promise, and it doesn't, promise methods (`.then`, `.catch`) can't be called on it.
After the decaffeination, this is likely due to a function that was returning a promise, but someone thought this returned value was the result of an unnecessary implicit return and removed the `return`. Re-returning the promise should fix the problem.

### Uncaught SyntaxError: missing } after property list[...]
Hot module reload messed up(?), just reload the page

### TypeError: foo.includes is not a function
`foo` was expected to be an array (could also be a string, but unlikely), but was actually something else, possibly a browser pseudo-array, which don't have the method `includes`: if you are indeed dealing with a pseudo-array, the solution is to transform it into a proper array: `Array.from(foo).includes`

### TypeError: _options is null
decaffeinte `--loose` option meant that
```coffee
someFn = (options = {})-> options * 2
```
was transformed into
```js
const someFn = (options = {}) => options * 2
```
which can be problematic as [default function parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters) are only triggered by `undefined` in JS, while both `undefined` and `null` were triggering it in CS.
Fix: replace by
```js
const someFn = options => {
  // When falsy values (undefined, null, 0, '') might be valid arguments
  if (options == null) options = {}
  // or, when falsy values will never be used, the following is also possible
  options = options || {}
  return b * 2
}
```
Known case where `null` is passed and we were using default parameters in CS: route callbacks

### Uncaught ReferenceError: can't access lexical declaration '__WEBPACK_DEFAULT_EXPORT__' before initialization
You might be dealing with a circular dependancy, see https://github.com/webpack/webpack/issues/9173#issuecomment-494903242

## In Webpack logs
### ERROR in ./node_modules/svelte/index.mjs 1:0-167
```
ERROR in ./node_modules/svelte/index.mjs 1:0-167
Module not found: Error: Can't resolve './internal' in '/home/maxlath/code/inventaire/inventaire/client/node_modules/svelte'
Did you mean 'index.mjs'?
BREAKING CHANGE: The request './internal' failed to resolve only because it was resolved as fully specified
(probably because the origin is a '*.mjs' file or a '*.js' file where the package.json contains '"type": "module"').
The extension in the request is mandatory for it to be fully specified.
Add the extension to the request.
```
This kind of error is due to the difficulties to work between ESM and CJS imports, and modules relying on the resolution of index.js files: it might be that it could be fixed from the webpack config, but in the meantime, a workaround is to make the import more specific:

If the error was triggered by an import such as
```js
import { onMount } from 'svelte'
```
it can be solved by replacing it by the more specific
```js
import { onMount } from 'svelte/internal/index.mjs'
```

### Cannot read property 'data' of undefined
See https://github.com/sveltejs/svelte-loader/issues/139
Should have been fixed by `npm i svelte-loader@https://github.com/smittyvb/svelte-loader#284238e`
