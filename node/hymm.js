'use strict';

var express = require('express');
var app = express()
var server = require('http').Server(app);

server.listen(80);

var hri = require('human-readable-ids').hri;

var bodyParser = require('body-parser');
var async = require('async');
var spotify = require('spotify-web-api-node');

var jwt = require('jsonwebtoken');
var jwt_secret = '#nS{cxX)[jMFV%d3in"Rz[(CW|N?tn~oD-d+Dt--&!:R8x=5^:oikj!?j+$Q6yqU/k2bF_WO{;c;+H3w4{@G"3;PF_,7Aem3cvz%~dcRMzjasJpy"k{3-HhqOPAlDm^$';

var db = require('monk')('localhost/hymm');
var users = db.get('users');
var spaces = db.get('spaces');

var pm2 = require('pm2');

 var portfinder = require('portfinder');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(function(req,res,next){
    res.setHeader('X-Powered-By', 'hymm');
    res.setHeader('Access-Control-Allow-Origin', '*');
    next();
}); 

app.get('/', function(req, res) {
	res.send('<iframe src="https://embed.spotify.com/?uri=spotify%3Atrack%3A3RiPr603aXAoi4GHyXx0uy" width="300" height="380" frameborder="0" allowtransparency="true"></iframe>');
});

app.post('/user/login', function(req, res) {
	if (req.body.username) {
		users.findOne({username: req.body.username}, function(err, doc) {
			if (doc){
				var token = jwt.sign({id: doc._id, username: req.body.username}, jwt_secret);
				res.json({success: true, auth_token: token});
			}else{
				
				var user_json = {username: req.body.username, sp_accessToken: req.body.access_token};
				users.insert(user_json, function(err, doc) {
					if (err) {
						res.status(400).send({success: false, message: err});
					}else {
						var token = jwt.sign({id: doc._id, username: req.body.username}, jwt_secret);
						res.json({success: true, auth_token: token});
					}	
				});
			}
		});
	}
});


var router = express.Router();

router.use(function(req, res, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token) {
		jwt.verify(token, jwt_secret, function(err, decoded) {
			if (err) {
				res.status(403).send({success: false, message: 'Authentication failed. There is an issue with the token.'});
			}else {
				req.user_id = decoded.id;
				req.user_name = decoded.username;
				next();
			}
		});
	}else {
		res.status(403).send({success: false, message: 'Authentication failed. No token was provided.'});
	}
	
});


router.route('/user')
	.get(function(req, res) {
		res.json({user_id:req.user_id});
	});
	
router.route('/user/space')

	.get(function(req, res) {
		if (req.query.share_id) {
			spaces.findOne({share_id: req.query.share_id}, function(err, doc) {
				if (doc) {
					doc.members.push(req.user_id);
					spaces.updateById(doc._id, doc, function(){
						console.log("User: " + req.user_id + " ["+ req.user_name +"] added to space: " + doc._id + " [" + req.query.share_id + "]");
						var base_url = 'http://api.hymm.io:' + doc.ws_port;
						res.json({success:true, base_url: base_url, space_id: '/'+ doc._id, song_uri: null});
					});
				}else {
					console.error("Space " + req.query.share_id + " not found!")
					res.json({success: false, message: 'Space not found.'});
				}
			})
		}
	})
	
	.post(function(req, res) {
		if (req.user_id) {
			var share_id = hri.random();
			portfinder.getPort(function (err, port) {
				var space_json = {share_id: share_id, created_by: req.user_id, members:[req.user_id], ws_port: port, queue: []};
				spaces.insert(space_json ,function(err, doc) {
					if (doc) {
						
						pm2.connect(function(err) {
							if (!err) {
							 pm2.start({
							 	name: "space-"+share_id,
							    script : 'space.js',
							    merge_logs : true,
							    log_date_format : "YYYY-MM-DD HH:mm Z",
							    autorestart : false,
							    args: [doc._id, share_id, req.user_name, port]
							  }, function(err, apps) {
							    pm2.disconnect();
							  });
							}
						});
						
						console.log("New space created by: " + req.user_id + " [" + req.user_name +"]. Share id: " + share_id + ". Port: " + port);
						var base_url = 'http://api.hymm.io:' + port;
						res.json({success:true, space_id: '/'+doc._id, share_id: share_id, ws_port: port, base_url: base_url});
					}
				});
			});
		}
	});

router.route('/space/queue')

	.get(function(req, res) {
		if (req.query.space_id) {
			spaces.findById(req.query.space_id, function(err, doc){
				if (doc) {
					res.json({success:true, queue: doc.queue});
				}else {
					console.error("Space " + req.query.space_id + " not found!")
					res.json({success: false, message: 'Space not found.'});
				}
			});
		}
	})
	
	.post(function(req, res) {
		if (req.query.space_id) {
			spaces.findById(req.query.space_id, function(err, doc){
				if (doc) {
					doc.queue.push({spotify_uri: req.body.spotify_uri, song_length: req.body.song_length});
					spaces.updateById(doc._id, doc, function(){
						res.json({success:true});
					});
					
				}else {
					console.error("Space " + req.query.space_id + " not found!")
					res.json({success: false, message: 'Space not found.'});
				}
			});		
		
		}
	});

	
app.use('/', router);
console.log("hymm is alive");