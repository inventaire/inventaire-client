import type { SerializedUser } from '#server/types/user'

// From the client point of view, all users are server-serialized
// The client can then perform further serialization
export type User = SerializedUser
