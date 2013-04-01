﻿<#
    
    Author: Ian Philpot (http://adminian.com)
    File: DNSimple.psm1
    Description: Module for working with DNSimple API.

#>

function GetRequest
{

}

function PutRequest
{
    param(
        $url,
        $jsonData,
        $emailAddress,
        $domainApiToken
    )

    [System.Net.HttpWebRequest]$request = [System.Net.WebRequest]::Create($url)
    $request.Accept = "application/json"
    $request.ContentType = "application/json" 
    $request.Method = "PUT"
    $dnsimpleToken = $emailAddress + ":" + $domainApiToken
    $request.Headers.add("X-DNSimple-Token", $dnsimpleToken)
    $request.ContentLength = $jsonData.ToString().length

    [System.IO.StreamWriter]$writer = $request.GetRequestStream()
    $writer.Write($jsonData)
    $writer.Close()

    $response = $request.GetResponse()
    $stream = $response.GetResponseStream()
    $reader = New-object System.IO.StreamReader($stream)
    $json = ConvertFrom-Json ($reader.ReadToEnd())
    $reader.Dispose()

    return $json
}

function Update-SMPLDomainRecord
{
    param(
        $name,
        $content,
        $ttl,
        $prio,
        $domain,
        $recordID,
        $emailAddress,
        $domainApiToken
    )

    $url = "https://dnsimple.com/domains/$domain/records/$recordID"
    $items = @{"record"=@{}}

    if ($name)
    {
        $items.record.name = $name
    }

    if ($content)
    {
        $items.record.content = $content
    }

    if ($ttl)
    {
        $items.record.ttl = $ttl
    }

    if ($prio)
    {
        $items.record.prio = $prio
    }

    $jsonData = $items | ConvertTo-Json

    $response = PutRequest -url $url -jsonData $jsonData -emailAddress $emailAddress -domainApiToken $domainApiToken

    $response.record
}

Export-ModuleMember -Function Update-SMPLDomainRecord