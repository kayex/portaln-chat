NETCODES = {
  AUTH_REQ: 0,
  AUTH_RES: 1,
  MSG_SEND_REQ: 2,
  MSG_SEND_RES: 3,
  MSG: 4
}

if not window?
  module.exports = exports
  exports.NETCODES = NETCODES
else
  window.NETCODES = NETCODES