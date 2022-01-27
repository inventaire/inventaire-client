import EntityValueEditor from '../editor/entity_value_editor.svelte'
import StringValueEditor from '../editor/string_value_editor.svelte'
import FixedStringValue from '../editor/fixed_string_value.svelte'
import SimpleDayValueEditor from '../editor/simple_day_value_editor.svelte'
import PositiveIntegerValueEditor from '../editor/positive_integer_value_editor.svelte'
import PositiveIntegerStringValueEditor from '../editor/positive_integer_string_value_editor.svelte'
import ImageValueEditor from '../editor/image_value_editor.svelte'

export const editors = {
  entity: EntityValueEditor,
  string: StringValueEditor,
  'fixed-string': FixedStringValue,
  'simple-day': SimpleDayValueEditor,
  'positive-integer': PositiveIntegerValueEditor,
  'positive-integer-string': PositiveIntegerStringValueEditor,
  image: ImageValueEditor,
}
