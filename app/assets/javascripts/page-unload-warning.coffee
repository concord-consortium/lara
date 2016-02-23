_locks = {}
_lockId = 0

window.addEventListener('beforeunload', (event) =>
  if Object.keys(_locks).length > 0
    message = t('DATA_MAY_BE_LOST')
    event.returnValue = message # Gecko, Trident, Chrome 34+
    message                     # Gecko, WebKit, Chrome <34
)

window.lockPageUnload = () ->
  id = _lockId++
  _locks[id] = true
  return id

window.unlockPageUnload = (id) ->
  delete _locks[id]
