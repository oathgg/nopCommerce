<#

    This tool fixes all the broken references.
        SF references contents/nl/xxxxx.html
        Nopcommerce uses Ids

#>

$ErrorActionPreference = "STOP";
$VerbosePreference = "SilentlyContinue";

Get-Module SQLPS -ErrorAction SilentlyContinue | Remove-Module;
Import-Module SQLPS;

function Get-Id ([string] $Str) {
    $Str = $Str.Replace(".html", "");

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

function Get-EntityFromId([string] $Id) {
    $entity = "";
    switch ($Id[0])
    {
        "d" {$entity = "Category"; break;}
        "p" {$entity = "Product"; break;}
        default {Write-Warning "Can't parse entity: $($Id[0])"}
    }

    return $entity;
}

function Fix-Id ([string] $Entity, [string] $Id) {
    Write-Verbose "ID: $Id";

    # The ID could've changed, so we do a select on the ObjId and then get the ID from that row so we can find the ID in nopcommerce.

    [int] $idWithoutType = $Id.Substring(1, $id.Length - 1);
    $Query = "SELECT SLUG FROM [NOPCOMMERCE_BLANK]..[URLRECORD] WHERE ENTITYNAME = '$Entity' AND ENTITYID = $idWithoutType";
    Write-Verbose $Query; 

    $result = Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Query $Query -QueryTimeout 65000;
    $newId = $result.SLUG;
    return $newId;
}

function Fix-Description ([string] $Entity, [string] $FieldName) {
    $Query = "SELECT Id, [$FieldName] FROM [NOPCOMMERCE_BLANK]..[$Entity] WHERE [$FieldName] LIKE '%.html%'";
    $result = Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Query $Query -QueryTimeout 65000;

    foreach ($row in $result) {
        $RecId = $row.Item(0)
        $originalDesc = $row.Item(1);
        $newDescr = $originalDesc;
        Write-Verbose "curDescr: $originalDesc";
        $Urls = $originalDesc.Split('"') | ? { $_ -imatch ".html" };

        # Fixes all the URL references within the HTML description tags
        foreach ($originalUrl in $Urls) {
            Write-Verbose "URL: $originalUrl";
            
            # When it's a full URL then we trust it's fine and we can leave it as is.
            if ($originalUrl -imatch "http") {
                Write-Verbose "Skipping $originalUrl";
                Continue;
            }

            $originalId = Get-Id -Str $originalUrl;
            # The reference might reference a different group than the initial category we are looping for...
            # A product can always reference a category and vice versa, get the group from the ID as they prefix it.
            $referencedEntity = Get-EntityFromId -Id $originalId;
            $newId = Fix-Id -Entity $referencedEntity -Id $originalId;
            
            $originalFullUrl = "contents/nl/$originalUrl";
            if (![string]::IsNullOrEmpty($newId)) {
                #Write-Host "FIXING LINK: ($Entity -> $RecId) $originalFullUrl -> $newId";
                $newDescr = $newDescr.Replace($originalUrl, $newId);
            } else {
                $newDescr = $newDescr.Replace($originalUrl, "#");
                Write-Warning "DEAD LINK: ($Entity -> $RecId) $originalFullUrl";
            }
        }

        # Updates the original description with the new references
        if (-not [string]::IsNullOrEmpty($newDescr)) {
            Write-Verbose $originalDesc;
            Write-Verbose "Will be updated to:"
            Write-Verbose $newDescr;

            # Make the new description SQL safe.
            $newDescr = $newDescr.Replace("'", "''");

            $Query = "UPDATE [NOPCOMMERCE_BLANK]..[$ENTITY] SET $FieldName = '$newDescr' WHERE ID = $RecId";
            Invoke-Sqlcmd -ServerInstance "localhost\sqlexpress" -Query $Query -QueryTimeout 65000 -Verbose;
        }
    }
}

Fix-Description -Entity "Category" -FieldName "Description";
Fix-Description -Entity "Product" -FieldName "ShortDescription";
Fix-Description -Entity "Product" -FieldName "FullDescription";
