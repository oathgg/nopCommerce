<#
PRODUCT::
    To get the image which belongs to the ID we have to look for an IMG tag which has an ID property that matches our file name.
    The file has a prefix for the group it belongs to;
    P: Product
    D: Category

    IMG tag heeft een ID met 'IP<ID>' voor Product

    ```
    p44510.html
    <img width="90" height="110" src="../media/trans.gif" data-echo="../media/t_versamagic%20dew%20drop%20niagara%20mist.jpg" class="DataEchoLoaded" id="IP44510" name="IP44510" border="0" alt="versamagic dew drop niagara mist" title="versamagic dew drop niagara mist" hspace="" vspace="" align="" onmouseover="window.status='versamagic dew drop niagara mist';return true;" onmouseout="window.status='';return true" />
    ```

    string van data-echo is de locatie van de image.
    image string is query encoded, '%20' is een spatie.

    https://stackoverflow.com/questions/23548386/how-do-i-replace-spaces-with-20-in-powershell
    To replace " " with %20 and / with %2F and so on, do the following:

    ```
    # Returns http%3A%2F%2Ftest.com%3Ftest%3Dmy%20value
    [uri]::EscapeDataString("http://test.com?test=my value")

    # Returns http://test.com?test=my%20value
    [uri]::EscapeUriString("http://test.com?test=my value") 
    ```

    To reverse this use the Unescape method
    ```
    [uri]::UnescapeDataString($SitePath)
    [uri]::UnescapeUriString($SitePath)
    ```

CATEGORY::
    

#>

$ErrorActionPreference = "STOP";
$VerbosePreference = "SilentlyContinue";

$RootContentFolder = "";
$RootMediaFolder = "";