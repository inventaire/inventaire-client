import type { SerializedEntity } from '#server/types/entity'

export type SerializedEntityWithLabel = SerializedEntity & {
  label: string
}
