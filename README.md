## ʃyslog-middleware

highly extendable, syslog-compatible UDP/TCP loggingdaemon with use()-middleware support (like express)

## Usage 

    $ npm install syslog++
    $ cp node_modules/syslog++/server.js .
    $ DEBUG=1 SYSLOG_HOST=127.0.0.1 SYSLOG_UDP_PORT=1338 SYSLOG_TCP_PORT=1337 node server.js
    input::syslog UDP Server listening on 127.0.0.1:1338

and then in another console:

    $ logger -d -P 1338 -i -p local3.info -t FLOP '{"flop":"flap","template":"{{indent:10:flop}}::{{indent:10:priority}}'"$(date)"'"}'

then the server would output this:

    flap       ::158        Mon Dec 28 22:29:08 CET 2015

see [test/test.coffee] for an example of sending syslogmessages using nodejs and [syslog-client](https://npmjs.org/syslog-client)

The basic design is i/p/o: `input ⟶ parser ⟶ output`, therefore highly extendable:

    varlogserver = require('syslog++');

    // inputs
    require('./src/input/syslog')(logserver);

    // parsers
    logserver.use(require('./src/parser/syslog'));
    logserver.use(require('./src/parser/brown'));

    // outputs
    logserver.outputs.push(require('./src/output/stdout'));

## Features

* highly extendable
* allows indenting / basic templating using brown
* automatically parses json when passed in syslog message
* uses [syslog-parse](https://npmjs.org/syslog-parse) as middleware message-format

## How can clients log to this?

Easy, using winston or the unix `logger` utility:

```javascript
const winston = require('winston');
require('winston-syslog')

const logger = winston.createLogger({ levels: winston.config.syslog.levels })
logger.add(new winston.transports.Syslog({
    port:1339,
    protocol:'tcp4',
    host: process.env.SYSLOG_HOST || 'localhost'
}))

// If we're not in production then log to the `console` with the format:
// `${info.level}: ${info.message} JSON.stringify({ ...rest }) `
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}
logger.log({level:'info', message:"this is a message"})
```


## Data format

The data which is passed around should be syslog-ish:

    { priority: 86,
      facilityCode: 10,
      facility: 'authpriv',
      severityCode: 6,
      severity: 'info',
      time: Mon Dec 28 2015 22:00:01 GMT+0100 (CET),
      host: 'peach',
      process: 'CRON',
      pid: 2607,
      template: "{{message}}"
      message: 'pam_unix(cron:session): session closed for user sqz' 
    }

> note that the `template` field is optional and triggers the brown template engine

## Template engine 

Like nice-aligned messages?
syslog++ uses [brown](https://npmjs.org/brown) as a template engine.

#### a template like:

    "{{process}} {{indent:40:message}} {{pid}}"

would overwrite the `message` field with the evaluated result:

    "CRON pam_unix(cron:session): session closed for user sqz              2607"

## Extend with Http request

Syslog is just one inputformat, you could for example also add an http input `input/http.js`:
    
    require('./src/input/http')(logserver);

where `input/http.js` is something like this:
 
    var http = require('http');

    module.exports = function(app){

      var server = http.createServer(function (request, response) {
      response.writeHead(200, {"Content-Type": "text/plain"});
        console.log "input::http" if app.verbosity > 1
        app.process(req.body);
        response.end('{"ok":true}\n');
      });
    
    }

The code above is untested, but the idea is just to call `app.process(data)` with data described in the __data format__ section 

## Todo 

* stresstest and use async to prevent volume problems
