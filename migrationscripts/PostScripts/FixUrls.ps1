#
# Script.ps1
#

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
    $Query;

    $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;
    $result;
}

$str = '<p><a href="p81553_Viva-Decor-Pouring-Medium.html">klik hier om naar het artikel te gaan</a></p> <p>&nbsp;</p>';
$url = $str.Split('"') | ? {$_ -imatch ".html"};
Fix-Url -Url $url;