cls;

$ErrorActionPreference = "STOP";
$VerbosePreference = "Continue";

Get-Module SQLPS -ErrorAction SilentlyContinue | Remove-Module;
Import-Module SQLPS;

function Fix-Id ([string] $Entity, [string] $Id) {
    Write-Verbose "ID '$Id'";

    [int] $idWithoutType = $Id.Substring(1, $id.Length - 1);
    $Query = "SELECT SLUG FROM [NOPCOMMERCE_BLANK]..[URLRECORD] WHERE ENTITYNAME = '$Entity' AND ENTITYID = $idWithoutType";
    Write-Verbose $Query; 

    $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;
    $newId = $result.SLUG;
    return $newId;
}

function Fix-Description ([string] $Entity, [string] $FieldName) {
    $Query = "SELECT [$FieldName] FROM [NOPCOMMERCE_BLANK]..[$Entity] WHERE [$FieldName] LIKE '%.html%'";
    $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;
    $strArr = $result | Select-Object -Property $FieldName -ExpandProperty $FieldName;

    foreach ($str in $strArr) {
        $str = $str | Select-Object -ExpandProperty $FieldName;
        
        Write-Verbose "STR: $str";

        $Urls = $str.Split('"') | ? { $_ -imatch ".html" };

        foreach ($url in $Urls) {
            Write-Verbose "URL: $url";
            
            if ($url -imatch "http") {
                Write-Verbose "Skipping $url";
                Continue;
            }

            # Remove .html tag
            $url = $url.Replace(".html", "");

            # Check if there is a # in the name.
            if ($url -imatch '#') {
                $url = $url.Split("#")[1];
            }
            if ($url -imatch ':') {
                $url = $url.Split(":")[1];
            }
            if ($url -imatch '_') {
                $url = $url.Split('_')[0];
            }

            $newId = Fix-Id -Entity $Entity -Id $url;

            if (![string]::IsNullOrEmpty($newId)) {
                Write-Host -ForegroundColor Green -BackgroundColor Black -Object "FIXED LINK: $fullUrl -> $newId";
                $str = $str.Replace($Url, $newId);
            } else {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "DEAD LINK: $url.html";
            }
        }
    }
}

Fix-Description -Entity "Category" -FieldName "Description";
Fix-Description -Entity "Product" -FieldName "ShortDescription";
Fix-Description -Entity "Product" -FieldName "FullDescription";
