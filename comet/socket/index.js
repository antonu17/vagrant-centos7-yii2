/**
 * Created by Rus on 08.07.2015.
 */

/*

 // sending to sender-client only
 socket.emit('message', "this is a test");

 // sending to all clients, include sender
 io.emit('message', "this is a test");

 // sending to all clients except sender
 socket.broadcast.emit('message', "this is a test");

 // sending to all clients in 'game' room(channel) except sender
 socket.broadcast.to('game').emit('message', 'nice game');

 // sending to all clients in 'game' room(channel), include sender
 io.in('game').emit('message', 'cool game');

 // sending to sender client, only if they are in 'game' room(channel)
 socket.to('game').emit('message', 'enjoy the game');

 // sending to all clients in namespace 'myNamespace', include sender
 io.of('myNamespace').emit('message', 'gg');

 // sending to individual socketid
 socket.broadcast.to(socketid).emit('message', 'for your eyes only');

 */


var log = require('libs/log')(module);


// Хранилище для лотов торгового виджета
var auctions = {};


/*
 var io = require('socket.io').listen(server, {
     origins: function (origin, fn) {
         var host = config.get('NODE_ENV') == 'development' ? config.get('origin-development') : config.get('origin-production');
         if (origin !== host) {
             log.info('allow origin: ' + origin);
             return fn(null, true);
         }
         log.warn('disallow origin: ' + origin);
         return fn(null, false);
     }
 });
*/
/*
 var host = config.get('NODE_ENV') == 'development' ? config.get('origin-development') : config.get('origin-production');
 io.set('origins', config.get('NODE_ENV') == 'development' ? config.get('origin-development') : config.get('origin-production'));
*/

module.exports = function(server) {

    var io = require('socket.io').listen(server);
    var rd = require('redis');
    //var redis = require('socket.io-redis');
    //io.adapter(redis({ host: 'localhost', port: 6379 }));
    var timer;
    var tick;

    io.on('connection', function (socket) {
        // комнаты для торга
        var rooms = [];



        var redis = rd.createClient();
        /**
         * Join client to private room
         */
        var sessId = _getPhpSessionId(socket.handshake.headers['cookie']);
        if (typeof sessId !== 'undefined') {


            /**
             * Private channel proxy
             */
            socket.on('_subscribe', function (channel, callback) {
                //log.info('NODEjs: subscribe to private channel: ' + 'user.' + sessId);
                redis.subscribe('user.' + sessId);
                callback({"result":true, "sid":socket.id});
            });


            /**
             * Public channel proxy
             */
            socket.on('subscribe', function (channel, callback) {
                //log.info('NODEjs: subscribe to public channel: ' + channel);
                redis.subscribe(channel);
                callback('NODEjs: subscribe to public channel: ' + channel);
            });


            /**
             * Redis listaner and broadcat to sockets
             */
            redis.on("message", function(channel, string){
                var data = JSON.parse(string);
                socket.emit(data.event, data.data);
            });












            // Auction proxy

            socket.on('auction', function (id, callback) {
                // @todo сделать проверку на доступность комнаты для текущего юзера

                // подключаем юзера к комнате где будте происходить торг
                socket.join('auction.' + id );
                // запоминаем комнату, чтоб в будущем отсылать уведомления о выходе из нее другим юзерам комнаты
                rooms.push(id);
                // сообщаем оппоненту о присоединении
                socket.to('auction.' + id).emit('auction', {
                    id: id,
                    data: {
                        event: "status",
                        params: "online"
                    }
                });

                // если уже есть данные по торгам, то передаем данные для синхронизации
                if (typeof auctions[id] !== 'undefined') {
                    callback(id, auctions[id]);
                } else {
                    // создаем модель лота
                    var model = {
                        id:             id,
                        step:           0,
                        maxStep:        5,
                        first:          'partner',
                        queue:          'partner',
                        price:          0.00,
                        commit:         false,
                        discount:       0.00,
                        startTime:      0,
                        timeLeft:       0,
                        roundTimeout:   60000,      // автоматическое окончание раунда
                        progress:       0,          // текущее положение прогрес-бара
                        status:         'waiting',
                        error:          '',
                        lastPrPrice:    0.00,       // последняя введенная цена партнера
                        lastOwPrice:    0.00,       // последняя введенная цена создателя сделка
                        bids:   {                   // ставки
                                    partner: [],
                                    owner: []
                        }
                    };
                    auctions[id] = model;

                    // В подтверждение о соединении возвращаем модель виджета
                    callback(id, model);
                }

            });


            // Auction events

            socket.on('auction-data', function (data, callback) {
                var item    = data.data
                    , event = item.event
                    , id    = data.id
                    , bid   = item.params
                    , model = auctions[id];

                /**
                 * Инициализация последней цены для юзеров
                 */
                if (event === 'init') {
                    if (model.price == 0 && model.lastPrPrice == 0 && model.lastOwPrice == 0) {
                        model.price = item.params.ownerPrice;
                        model.lastPrPrice = item.params.partnerPrice;
                        model.lastOwPrice = item.params.ownerPrice;
                        model.discount = item.params.discount;
                    }
                }

                /**
                 * Фиксация цены, т.е. цена окончательно подтверждена партнером
                 */
                if (event === 'commit') {
                    if (model.price > 0) {
                        model.commit = true;
                    }
                }

                /**
                 * Фиксация цены, т.е. цена окончательно подтверждена партнером
                 */
                if (event === 'error') {
                    model.status = 'error';
                    model.error = item.params.error;
                }


                /**
                 * Новая ставка по цене
                 */
                if (event === 'bid') {
                    model.price      = bid.price;
                    model.discount   = bid.discount;
                    model.bids[model.queue][model.step] = {
                        price:      bid.price,
                        discount:   bid.discount
                    };

                    // запоминаем последнюю цену юзера
                    model.queue == 'partner' ?
                        model.lastPrPrice = bid.price:
                        model.lastOwPrice = bid.price;

                    revertQueue( model );

                    // завершение торга если превышено кол-во шагов
                    if (model.status === 'finish') {
                        clearInterval(timer);
                    }
                    // Подтверждение в получении ставки
                    callback(model);
                }


                /**
                 * Запускаем процесс торга.
                 * Процессом управляет таймер timer.
                 * Если ставка не приходит от юзера, то она ставится автоматически. При этом уведомляются оба участника.
                 * Если ставка приходит от юзера, то просто обнуляем progress.
                 */
                if (event === 'start') {
                    model.status = 'running';
                    model.startTime = Date.now();
                    model.progress = 0;
                    model.timeLeft = model.roundTimeout / 1000;
                    // запускаем процесс торга
                    tick = 100 / (model.roundTimeout / 1000);
                    // запускаем таймер для автоматической передачи хода
                    timer = setInterval(function(){
                        model.progress = model.progress + tick;
                        sendProgress(model);
                        if (model.progress >= 100) {
                            // завершаем раунд автоматически
                            if (model.queue === 'partner' && model.step == 0) {
                                // Если это первый ход и партнер ничего не указал, то автоматически снижаем на 1%
                                model.lastPrPrice = model.lastPrPrice - (model.lastPrPrice * 0.01);
                                model.price = model.lastPrPrice;
                                model.discount = 1.00;
                            } else {
                                // Далее торгуемся по последним введенным ценам
                                model.price = model.queue === 'partner' ?
                                    model.lastPrPrice:
                                    model.lastOwPrice;
                            }
                            model.bids[model.queue][model.step] = {
                                price:      model.price,
                                discount:   model.discount
                            };
                            // меняем очередь
                            revertQueue( model );
                            // высылаем обоим новую модель и команду о смене очереди
                            io.in('auction.' + model.id).emit('auction', {
                                id:     model.id,
                                data: {
                                    event: "revert",
                                    params: model
                                }
                            });
                            // если кол-во шагов превышено, то автоматически завершаем торг
                            if (model.status === 'finish') {
                                console.log(model.id + ': finishing...');
                                clearInterval(timer);
                            }
                        }
                    }, 1000);

                    // Подтверждение старта
                    callback(model);
                }

                /**
                 * Завершение торга
                 */
                if (event === 'finish') {
                    model.status = 'finish';
                    clearInterval(timer);
                }


                /**
                 * Отмена торга
                 */
                if (event === 'cancel') {
                    if (typeof model != 'undefined') {
                        model.status = 'canceled';
                        clearInterval(timer);
                    }
                }


                /**
                 * Прямая передача состояния одного юзера другому
                 */
                if (event === 'status') {
                    socket.to('auction.' + id).emit('auction', {
                        id:     id,
                        data: {
                            event: event,
                            params: item.params
                        }
                    });
                }

                // Всегда передаем измененную модель
                socket.to('auction.' + id).emit('auction', {
                    id: id,
                    data: {
                        event: event,
                        params: model
                    }
                });

                // Очищаем память (!)
                // @todo определить, действительно ли очищается память?
                if (model.status == 'canceled' || model.status == 'error' || model.status == 'commit') {
                    delete auctions[id];
                }

            });














            /**
             * Action for disconected user
             */
            socket.on('disconnect', function () {
                if (rooms.length) {
                    for (var i=0; i < rooms.length; ++i) {
                        socket.to('auction.' + rooms[i]).emit('auction', {id:rooms[i], data:{event:"status", params:"offline"}});
                    }
                }
                redis.unsubscribe('user.' + sessId);
                redis.quit();
            });
        }

    });

    /**
     * Передаем очередь другому юзеру
     * @param model
     */
    function revertQueue(model) {
        model.progress = 0;
        model.startTime    = Date.now();

        if (model.queue !== model.first)
            model.step = model.step + 1;

        model.queue = model.queue === 'owner' ?
            'partner' :
            'owner';

        model.status = model.step >= model.maxStep ?
            'finish':
            'running';

        model.timeLeft = model.roundTimeout / 1000;
    }

    /**
     * Отсылаем юзерам временя окончания хода
     * @param model
     */
    function sendProgress(model) {
        io.in('auction.' + model.id).emit('auction', {
            id:  model.id,
            data: {
                event: "complete",
                params: {value: model.progress, left: model.timeLeft--}
            }
        });
    }



    /**
     *  Parse cookie from headers
     */
    function _parseCookies(_cookies) {
        var cookies = {};

        _cookies && _cookies.split(';').forEach(function( cookie ) {
            var parts = cookie.split('=');
            cookies[ parts[ 0 ].trim() ] = ( parts[ 1 ] || '' ).trim();
        });

        return cookies;
    }

    /**
     * Extract php session id from cookie
     * @param cookiesStr string simple cookie string from headers
     * @returns string
     */
    function _getPhpSessionId(cookiesStr) {
        var cookies = _parseCookies(cookiesStr);
        return cookies.PHPSESSID
    }
};


