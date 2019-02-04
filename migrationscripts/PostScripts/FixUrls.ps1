cls;

$ErrorActionPreference = "STOP";
$VerbosePreference = "SilentlyContinue";

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
    $Query = "SELECT Id, [$FieldName] FROM [NOPCOMMERCE_BLANK]..[$Entity] WHERE [$FieldName] LIKE '%.html%'";
    $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;

    foreach ($row in $result) {
        $RecId = $row.Item(0)
        $curDescr = $row.Item(1);
        $newDescr = "";
        
        # String to be editted.
        Write-Verbose "curDescr: $curDescr";

        $Urls = $curDescr.Split('"') | ? { $_ -imatch ".html" };

        foreach ($url in $Urls) {
            Write-Verbose "URL: $url";
            
            if ($url -imatch "http") {
                Write-Verbose "Skipping $url";
                Continue;
            }

            $id = Get-Id -Str $url;
            $newId = Fix-Id -Entity $Entity -Id $id;
            $oldUrl = "contents/nl/$url";

            if (![string]::IsNullOrEmpty($newId)) {
                Write-Host -ForegroundColor Green -BackgroundColor Black -Object "FIXED LINK: ($Entity->$RecId) $oldUrl -> $newId";
                $newDescr = $curDescr.Replace($Url, $newId);
            } else {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "DEAD LINK: ($Entity->$RecId) $oldUrl";
            }
        }

        if (![string]::IsNullOrEmpty($newDescr)) {
            # Make the new description SQL safe.
            $newDescr = $newDescr.Replace("'", "''");

            $Query = "UPDATE [NOPCOMMERCE_BLANK]..[$ENTITY] SET $FieldName = '$newDescr' WHERE ID = $RecId";
            Write-Verbose $Query;
            $result = Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Query $Query -QueryTimeout 65000;
        }
    }
}

function Get-Id ([string] $Str) {
    $Str = $Str.Replace(".html", "");

    # Check if there is a # in the name.
    if ($Str -imatch '#') {
        $Str = $Str.Split("#")[1];
    }
    if ($Str -imatch ':') {
        $Str = $Str.Split(":")[1];
    }
    if ($Str -imatch '_') {
        $Str = $Str.Split('_')[0];
    }

    return $Str;
}

Fix-Description -Entity "Category" -FieldName "Description";
Fix-Description -Entity "Product" -FieldName "ShortDescription";
Fix-Description -Entity "Product" -FieldName "FullDescription";
