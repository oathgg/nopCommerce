"use strict";
function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 30000, //< Default Max Timout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    //console.log("'waitFor()' timeout");
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    //console.log("'waitFor()' finished in " + (new Date().getTime() - start) + "ms.");
                    typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 500); //< repeat check every 250ms
};

var fs = require('fs');
var page = require('webpage').create();
page.viewportSize = { width: 1024, height: 768 };

page.open("https://creawerk.nl/contents/nl/d3610.html", function() {
	waitFor(function() {
			// Check in the page if a specific element is now visible
			return page.evaluate(function() {
				return $(".idx2Submenu").is(":visible");
			});
		}, function() {
		   //console.log("IDX Should be visible");
		   //page.render('export.png');
		   //fs.write('1.html', page.content, 'w');
		   console.log(page.content);
		   phantom.exit();
		});
});