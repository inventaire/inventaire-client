import { currentRoute } from 'lib/location'
const routeAllowlist = [
  'signup',
  'login',
  'login/reset-password'
]

export default function (e) {
  // Allow submit on singup and login to let password managers react to the submit event
  if (routeAllowlist.includes(currentRoute())) return
  e.preventDefault()
}
