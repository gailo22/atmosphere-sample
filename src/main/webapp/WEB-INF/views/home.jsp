<%@ include file="/WEB-INF/views/includes/taglibs.jsp"%>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Home - Atmosphere</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="">
		<meta name="author" content="">

		<!-- Le styles -->

		<link href="<c:url value='/assets/css/bootstrap.css'/>" rel="stylesheet" />
		<link href="<c:url value='/assets/css/custom.css'/>" rel="stylesheet" />
		<link href="<c:url value='/assets/css/bootstrap-responsive.css'/>" rel="stylesheet" />
		<link href="<c:url value='/assets/css/scales.css'/>" rel="stylesheet" />

		<!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
		<!--[if lt IE 9]>
			<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->

		<!-- Le fav and touch icons -->
		<link rel="shortcut icon" href="<c:url value='/assets/ico/favicon.ico'/>">
		<link rel="apple-touch-icon-precomposed" sizes="144x144" href="<c:url value='/assets/ico/apple-touch-icon-144-precomposed.png'/>">
		<link rel="apple-touch-icon-precomposed" sizes="114x114" href="<c:url value='/assets/ico/apple-touch-icon-114-precomposed.png'/>">
		<link rel="apple-touch-icon-precomposed" sizes="72x72" href="<c:url value='/assets/ico/apple-touch-icon-72-precomposed.png'/>">
		<link rel="apple-touch-icon-precomposed" href="<c:url value='/assets/ico/apple-touch-icon-57-precomposed.png'/>">
		
	</head>

	<body>
		<div class="navbar navbar-fixed-top">
				<div class="navbar-inner">
					<div class="container">
						<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
						</a>
						<a class="brand" href="#">Graph - atmosphere</a>
					</div>
				</div>
			</div>
			
			<div class="container">
				<div class="page-header">
					<h1>Graph <small>Atmosphere</small></h1>
				</div>
				<div id="chart_div" style="width: 900px; height: 500px;"></div>
			</div>
			
	
		<!-- JavaScript -->
		<script src="<c:url value='/assets/js/jquery.js'/>"></script>
		<script src="<c:url value='/assets/js/bootstrap.js'/>"></script>
		<script src="<c:url value='/assets/js/jquery.atmosphere.js'/>"></script>
		<script src="<c:url value='/assets/js/custom.js'/>"></script>

		<script type="text/javascript" src="<c:url value='/assets/js/d3.js'/>"></script>
		<script src="<c:url value='/assets/js/custom-lisram-chart.js'/>"></script>
		
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>

		<script type="text/javascript">
			google.load("visualization", "1", {packages:["corechart"]});
	      	google.setOnLoadCallback(drawChart);
	      	
	      	var dateKeys = [];
	      	
			$(function() {

				if (!window.console) {
					console = {log: function() {}};
				}

				$.mynamespace = {
					lisramChart : null,
					dates: []
				};

				var socket = $.atmosphere;
				var transport = 'websocket';
				var websocketUrl = "${fn:replace(r.requestURL, r.requestURI, '')}${r.contextPath}/websockets/";

				console.log('websocketUrl: ' + websocketUrl);

				var request = {
						url: websocketUrl,
						contentType : "application/json",
						logLevel : 'debug',
						transport : transport ,
						fallbackTransport: 'long-polling',
						onMessage: onMessage,
						onOpen: function(response) {
							console.log('Atmosphere onOpen: Atmosphere connected using ' + response.transport);
							transport = response.transport;
						},
						onReconnect: function (request, response) {
							console.log("Atmosphere onReconnect: Reconnecting");
						},
						onClose: function(response) {
							console.log('Atmosphere onClose executed');
						},

						onError: function(response) {
							console.log('Atmosphere onError: Sorry, but there is some problem with your '
								+ 'socket or the server is down');
						}
				};

				var subSocket = socket.subscribe(request);

				function onMessage(response) {
					var message = response.responseBody;
					console.log('message: ' + message);

					var result;

					try {
						result =  $.parseJSON(message);
					} catch (e) {
						console.log("An error ocurred while parsing the JSON Data: " + message.data + "; Error: " + e);
						return;
					}
					
					dateKeys = getAllProperties(result);
					
				    console.log("result : " + result);
				    console.log("dateKeys : " + dateKeys);
				    
				    drawChart(result);

					//$.mynamespace.dates.push(date);

				}
			});
			
			function drawChart(result) {
	      		
				if (result && !(result instanceof Event)) {
					var row1 = result[dateKeys[0]]["entry"];
					var row2 = result[dateKeys[1]]["entry"];
					
					console.log("row1 : " + row1);
					
			        var data = google.visualization.arrayToDataTable([
			          ['Hour', dateKeys[0],   dateKeys[1]],
			          ['1',  row1[0],      row2[0]],
			          ['2',  row1[1],      row2[1]],
			          ['3',  row1[2],      row2[2]],
			          ['4',  row1[3],      row2[3]]
			        ]);
			
			        var options = {
			          title: 'Atmosphere Monitoring'
			        };
			
			        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
			        chart.draw(data, options);
				}
		      }
			
			function getAllProperties(obj) {
				var properties = [];
				for (var key in obj) {
					if (obj.hasOwnProperty(key)) {
						properties.push(key);
					}
				}
				return properties;
			}
			
		</script>
		
	</body>
</html>