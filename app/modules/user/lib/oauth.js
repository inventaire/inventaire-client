export function getRequestedAccessRights (scope) {
  return scope
  .split(/[+\s]/)
  .map(accessRight => ({
    key: accessRight,
    label: accessRightCustomLabels[accessRight] || accessRight,
  }))
}

const accessRightCustomLabels = {
  email: 'access your email address',
  'stable-username': 'access your username',
}
