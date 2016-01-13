# TCP: $ logger --tcp -n 127.0.0.1 -P 1339 -i -p local3.info -t FLOP $(date)
# UDP: $ logger --udp -n 127.0.0.1 -P 1338 -i -p local3.info -t FLOP $(date)
try
  logserver = require './index'
catch e 
  logserver = require 'syslog++'

###
# inputs
###

require('syslogd-middleware/src/input/syslog')(logserver)

###
# parsers 
###

logserver.use require('syslogd-middleware/src/parser/syslog')
logserver.use require('syslogd-middleware/src/parser/brown')

###
# outputs
###

logserver.outputs.push require 'syslogd-middleware/src/output/stdout'
