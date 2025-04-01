import { API } from '#app/api/api'
import app from '#app/app'
import type { ErrorContext } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { commands } from '#app/radio'
import type { EntityUri } from '#server/types/entity'

export interface FeedbackParams {
  subject: string
  message?: string
  uris?: EntityUri[]
  unknownUser?: string
  context?: ErrorContext
}

export async function postFeedback (params: FeedbackParams) {
  if (params.context == null) params.context = {}
  // @ts-expect-error
  params.context.location = document.location.pathname + document.location.search
  log_.info(params, 'posting feedback')
  return preq.post(API.feedback, params)
}

type FeedbackModalOptions = Pick<FeedbackParams, 'subject' | 'uris'>

export async function showFeedbackModal (options: FeedbackModalOptions) {
  const { default: FeedbackMenu } = await import('#general/components/feedback_menu.svelte')
  app.layout.showChildComponent('modal', FeedbackMenu, {
    props: {
      standalone: false,
      ...options,
    },
  })
  commands.execute('modal:open')
}
