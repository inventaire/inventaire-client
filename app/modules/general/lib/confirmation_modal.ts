import app from '#app/app'
import { commands } from '#app/radio'

export interface ConfirmationModalProps {
  action: () => Promise<void> | void
  confirmationText: string
  warningText?: string
  formAction?: (formContent: string) => Promise<void>
  formLabel?: string
  formPlaceholder?: string
  yes?: string
  no?: string
  yesButtonClass?: 'string'
  back?: () => void
}

export async function askConfirmation (options: ConfirmationModalProps) {
  const { default: ConfirmationModal } = await import('#general/components/confirmation_modal.svelte')
  app.layout.showChildComponent('modal', ConfirmationModal, {
    props: options,
  })
  commands.execute('modal:open')
}
