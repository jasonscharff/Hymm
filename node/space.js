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


server.listen(ws_port);

var options = {refreshRateMS: 50 , almostDoneMS: 10000};
var timer = new Stopwatch();
timer.stop();
var song_length;

var nsp = io.of('/' + space_id);
console.log(space_id);

nsp.on('connection', function(socket){
	console.log('New Connection!');

	
	setTimeout(function() {
		console.log('New user, waiting half a second.');
		nsp.emit('force_seek', (currentspt_time+2500));
		console.log('Waited!');
	}, 1500);

	if (currentspt_time) {
		nsp.emit('seek', currentspt_time);	
	}
	if (current_song) {
		nsp.emit('next_song', current_song);	
	}
	
	socket.on('time_update', function (data) {
   		timer.reset(Math.abs(current_song_time-data));
   		timer.start();
	});
	
	socket.on('chosen_song', function (data) {
	
		console.log("all: ", data);
		console.log("uri: ", data.uri);
		console.log("duration: ", data.duration);
		
		current_song_time = data.duration;
		nsp.emit('next_song', data.uri);
		
		current_song = data.uri;
		
		timer.reset(current_song_time);
		//timer.start();

	});
	
	socket.on('pause', function (data) {
		timer.stop();
   		nsp.emit('pause_song', true);
	});
	
	socket.on('play', function (data) {
		nsp.emit('force_seek', currentspt_time);	
   		nsp.emit('play_song', true);
   		timer.start();
	});

	
});
 

timer.onTime(function(time) {
	currentspt_time = Math.abs(time.ms-current_song_time);
	
	
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





