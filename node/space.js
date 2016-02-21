'use strict'

var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

var Stopwatch = require('timer-stopwatch');
var SpotifyAPI = require('spotify-web-api-node');

var db = require('monk')('localhost/hymm');
var spaces = db.get('spaces');

var spotify = new SpotifyAPI({
  clientId : 'b086a25c3ff6445d9d327e8dd978a3e8',
  clientSecret : 'cf609d89b37c4d1fac27b8ac53674ed1',
  redirectUri : 'http://www.example.com/callback'
});

var argv = require('minimist')(process.argv.slice(2));

var space_id = process.argv[2];
var space_share_id = process.argv[3];
var req_user = process.argv[4];
var ws_port = process.argv[5];

var current_song_time = 0;
var current_song;
var next_song;
var next_song_time = 0;
var currentspt_time = 0;

var userWithControl = process.argv[4];

server.listen(ws_port);

var options = {refreshRateMS: 50 , almostDoneMS: 10000};
var timer = new Stopwatch();
var song_length;

var nsp = io.of('/' + space_id);
console.log(space_id);

nsp.on('connection', function(socket){
	console.log('connection!');
	
	socket.emit('seek', currentspt_time);
	socket.emit('next_song', current_song);
	
	socket.on('time_update', function (data) {
   		console.log(data);
   		timer.reset(Math.abs(current_song_time-msg[0]));
   		timer.start();
	});
	
	socket.on('chosen_song', function (data) {
		console.log(data);
		spotify.getTrack(data[0])
		.then(function(spdata) {
			console.log(data);
			console.log('spdata',spdata);
			current_song_time = spdata.body.duration_ms;
			nsp.emit('next_song', data[0]);
			
			current_song = data[0];
			
			timer.reset(current_song_time);
			timer.start();
			
		}, function(err) {
			console.error(err);
	});
	
});
	
	
});

/*

nsp.on('control_released', function (from, msg) {
	//
	nsp.emit('control_available', true);
});

nsp.on('secure_control', function (from,msg) {
	
});

nsp.on('pause_track', function (from,msg) {
	nsp.emit('pause', true);
	timer.stop();
});
*/

timer.onTime(function(time) {
	console.log(time);
	currentspt_time = Math.abs(time.ms-song_length);
	nsp.emit('seek', currentspt_time);
});

timer.onAlmostDone(function(almostDone) {
	
	spaces.findById(space_id, function(err, doc) {
		if (doc){
			try {
				next_song = doc[1].spotify_uri;
				next_song_time = doc[1].song_length;
			}
			catch (e) {
			  	next_song = null;
			  	next_song_time = null;
			  	console.log(e);
			}
			doc.splice(0,1);
			
			spaces.updateById(doc._id, doc, function(){
				current_song = next_song;
				current_song_time = next_song_time;
			});
		}
	});
	
    console.log('Timer is almost complete. Updating songs.');
});

timer.onDone(function() {

	socket.emit('next_song', current_song);
	timer.reset(current_song_time);
	timer.start();

    console.log('Timer is complete. Sending next song: ', current_song);
});





