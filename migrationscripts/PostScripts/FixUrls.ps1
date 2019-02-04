$ErrorActionPreference = "STOP";

#p81553_Viva-Decor-Pouring-Medium.html
function Fix-Url ([string] $Url) {
    Get-Module SQLPS -ErrorAction SilentlyContinue | Remove-Module;
    Import-Module SQLPS;

    $id = $url.Split('_')[0]; #p81553
    
    # Get the SLUG of the ID.
    $Type = "";
    switch ($id[0])
    {
        'p' { $Type = "Product"; break; }
        'd' { $Type = "Category"; break; }
    }

    $idWithoutType = $id.Substring(1, $id.Length - 1);
    $Query = "SELECT SLUG FROM [NOPCOMMERCE_BLANK]..[URLRECORD] WHERE ENTITYNAME = '$Type' AND ENTITYID = $idWithoutType";

    $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;
    $newUrl = "";
    if ($result -ne $null) {
        $newUrl = $result.SLUG;
    } else {
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "DEAD LINK: $url";
    }

    return $newUrl;
}

$str = '<p><a href="d2574_Viva_Decor_Inka_Gold_Metaalglans_.html">klik hier om naar het artikel te gaan</a></p> <p>&nbsp;</p>';
$url = $str.Split('"') | ? {$_ -imatch ".html"};

$newUrl = Fix-Url -Url $url;
if ($newUrl -ne "") {
    $str = $str.Replace($url, $newUrl);
} else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object $str;
}