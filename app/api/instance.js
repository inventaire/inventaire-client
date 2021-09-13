export const customizeInstance = url => {
  if (app.config.remoteEntities != null) {
    return `${app.config.remoteEntities}${url}`
  } else {
    return url
  }
}
