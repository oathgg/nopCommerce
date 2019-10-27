#
# UpdateCategoryImageLinks.ps1
#

$RootContentFolder = "C:\Temp\Creawerk_FTP\contents\nl";

$phantomJsScript = "`"use strict`";
function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 5000, //< Default Max Timout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === `"string`" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    //console.log(`"'waitFor()' finished in `" + (new Date().getTime() - start) + `"ms.`");
                    typeof(onReady) === `"string`" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 500); //< repeat check every 250ms
};

var fs = require('fs');
var page = require('webpage').create();
page.viewportSize = { width: 1024, height: 768 };

page.open('https://creawerk.nl/contents/nl/<WEBPAGE>', function() {
	waitFor(function() {
			// Check in the page if a specific element is now visible
			return page.evaluate(function() {
				return `$('.idx2Submenu').is(':visible');
			});
		}, function() {
		    fs.write('<WEBPAGE>.corrected', page.content, 'w');
		    phantom.exit();
		});
});"

function Write-Log ($Type, $Message) {
    $dateTime = Get-Date -Format "yyyyMMdd-HHmmss";
    $fullMessage = "$dateTime - [$Type] - $Message"
    
    Write-Host $fullMessage;
    $fullMessage >> "log.txt";
}

cd $RootContentFolder;
$htmlPages = Get-ChildItem | ? { $_.Name -match ".html" -and $_.Name -notmatch "phantom.js" -and $_.Name -notmatch ".corrected" };

for ($i = 0; $i -lt $htmlPages.Count; $i++) {
    $pageName = $htmlPages[$i].Name;

    if (Test-Path (Join-Path $RootContentFolder "$pageName.corrected")) {
        Write-Verbose "$pageName has already been corrected."
        continue;
    }
    
    $phantomJsFileName = (Join-Path $RootContentFolder "$pageName.phantom.js");
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False;
    Write-Verbose "Creating file $phantomJsFileName"
    [System.IO.File]::WriteAllLines($phantomJsFileName, $phantomJsScript.Replace("<WEBPAGE>", $pageName), $Utf8NoBomEncoding);

    Write-Log -Type "Information" -Message ".\PhantomJS.exe $phantomJsFileName;";
    $process = Start-Process -FilePath "C:\Temp\Creawerk_FTP\contents\nl\phantomjs.exe" -ArgumentList @($phantomJsFileName) -PassThru -NoNewWindow;
    $process.WaitForExit(500) | Out-Null; # 15 seconds

    $phantomProcesses = Get-Process -Name "PhantomJs" -ErrorAction Ignore;
    foreach ($p in $phantomProcesses) {
        if ($p.StartTime.AddSeconds(15) -lt [DateTime]::Now) {
            if (-not $p.HasExited) {
                Write-Warning ("Killing process " + $p.Id)
                $p.Kill();
            }
        }
    }
}