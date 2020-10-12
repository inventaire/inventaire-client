# Troubleshooting
For when you're looking for a clue of how to solve a problem

## "foo" is read-only
Some [ESM import](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Instructions/import) is being overriden somewhere, which is not allowed (esm import defines variables as constants)

## foo is undefined / foo is not a function
### option 1: foo is an imported variable
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

## TypeError: fooModuleName.default is undefined
It might be that there is no `export default` in the module you are trying to import, so `import fooModuleName from './foo_module_name` will fail. Possible solution: `import * as fooModuleName from './foo_module_name`

## TypeError: foo(...).then / foo(...).catch is not a function
Calling the function `foo` should have returned a promise, and it doesn't, promise methods (`.then`, `.catch`) can't be called on it.
After the decaffeination, this is likely due to a function that was returning a promise, but someone thought this returned value was the result of an unnecessary implicit return and removed the `return`. Re-returning the promise should fix the problem.

## Uncaught SyntaxError: missing } after property list[...]
Hot module reload messed up(?), just reload the page

## TypeError: foo.includes is not a function
`foo` was expected to be an array (could also be a string, but unlikely), but was actually something else, possibly a browser pseudo-array, which don't have the method `includes`: if you are indeed dealing with a pseudo-array, the solution is to transform it into a proper array: `Array.from(foo).includes`

## TypeError: _options is null
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

## nothing works, but it should
- try to restart `npm run watch`
- still not working: stop watcher, `rm -rf ./.cache`, restart watcher
- still not working: take a break :D
