export function displayAboveTopBar () {
  document.getElementById('main').style['z-index'] = '2'
}

export function resetDisplay () {
  document.getElementById('main').style['z-index'] = '0'
}
