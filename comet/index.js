var express = require('express');
var http = require('http');
var config = require('config');
var log = require('libs/log')(module);
var app = express();
//app.use(express.favicon());
//app.use(express.logger());

var server = http.createServer(app);

server.listen(config.get('port'), function(){
    log.info('Node server listening on *:' + config.get('port') +' port...');
    log.info('NODE_ENV: ' + config.get('NODE_ENV'));
});


/**
 * WebSocket Server started
 */
var sock = require('./socket')(server);


app.get('/', function(req, res){
    //res.send('<h1>Node server for TorBor service...</h1>');
    res.sendFile(__dirname + '/files/index.html');
});

app.get('/index', function (req, res) {
    res.sendFile(__dirname + '/files/403.html');
});

app.get('/auction', function (reg, res) {
    var data = {
        step: 2,
        queue: 'partner',
        price: 4250.80,
        discount: -8.89,
        startDate: 1438687079041,
        bids: {
            partner: {
                1: {
                    price: 4450.00,
                    discount: -2.22
                },
                2: {
                    price: 4455.50,
                    discount: -3.42
                },
                3: {
                    price: 4405.00,
                    discount: -3.88
                }
            },
            owner: {
                1: {
                    price: 4200.00,
                    discount: -3.56
                },
                2: {
                    price: 4250.80,
                    discount: -2.22
                }
            }
        }
    };
    //res.setHeader("Content-Type", "text/html");
    //res.type('json');
    res.jsonp(data);
});

app.get('/*', function (req, res) {
    res.sendFile(__dirname + '/files/404.html');
});