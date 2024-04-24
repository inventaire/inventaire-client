// Timeouts are identified by number in the browsers (while NodeJs uses Timeout objects)
export type TimeoutId = ReturnType<typeof setTimeout>
