﻿
    <#
.SYNOPSIS
    Creates the Sitecore solr cores/collections (solr standalone / solr cloud)
.DESCRIPTION
    Script to create all the the needed Sitecore cores/collections in Solr  
.PARAMETER command
    What to perform, create or delete Sitecore collections.   
.PARAMETER solrPath
    Path to the solr installation
.PARAMETER setupCores
    
.PARAMETER configName
    Name of the core/collection configuration name. You can create this configuration by using the sitecore-config-creator.ps1 script. 
.PARAMETER shards
    Number of shards for each collection
.PARAMETER replicationFactor
    Replication factor per collection 
.EXAMPLE
    C:\PS> sitecore-solr-cores-creation.ps1 -command create -solrPath C:\solr -configName sitecoreconf
.NOTES
    Author: Diego Saavedra San Juan
    Date:   Many
#>


param(
    [Parameter(Mandatory=$true)]
    [string]$command,
    [Parameter(Mandatory=$true)]
    [string]$solrPath,      # The path to the solr installation. We expect bin\solr.cmd to be there (for Sitecore 5+)
    [Parameter(Mandatory=$true)]
    [string]$configName,            # The configuration name to use for the cores/collections
    [string]$shards="1",
    [string]$replicationFactor="3")
        
    
$sitecore_collection_names=
"sitecore_testing_index",
"sitecore_suggested_test_index",
"sitecore_fxm_master_index",
"sitecore_fxm_web_index",
"sitecore_list_index",
"sitecore_analytics_index",
"sitecore_core_index",
"sitecore_master_index",
"sitecore_web_index",
"sitecore_marketing_asset_index_master",
"sitecore_marketing_asset_index_web",
"sitecore_marketingdefinitions_master",
"sitecore_marketingdefinitions_web",
"social_messages_master",
"social_messages_web"


$ErrorActionPreference = "stop"
Import-Module .\solr-powershell.psm1 -Force -ArgumentList @($solrPath) 


#Check-Collection-Exist -collectionName "sitecore_core_index"
Function Create-Sitecore-Collections {
    Write-Host "Creating Sitecore Collections" -ForegroundColor Cyan

    #if ( Check-Collection-Exists -collectionName "sitecore_core_index" )
    #{
    #    Write-Host "Sitecore collections already exist, skipping creation"
    #    return
    #}

    Write-Host "Creating Sitecore collection configuration" -ForegroundColor Cyan


    foreach ($collectionName in $sitecore_collection_names)
    {        
        
        if (Create-Collection -collectionName $collectionName -confdir "sitecoreconf" -configName $configName -shards $shards -replicationFactor $replicationFactor)
        {
            Write-Host "Collection $collectionName created sucessfully" -ForegroundColor Cyan
        }
        else 
        {
            Write-Error "Error creating collection $collectionName"
            return $false;
        }
        
        # Solr checks if the collection already exists
        #if ( -n Check-Collection-Exist -collectionName $collectionName )
        #{
        #    Create-Collection -collectionName $collectionName -confdir "sitecoreconf" -
        #}
    }
    Write-Host "Finished creating Sitecore collections" -ForegroundColor Green
}

Function Delete-Sitecore-Collections {
    Write-Host "Deleting Sitecore Collections" -ForegroundColor Cyan
    foreach ($collectionName in $sitecore_collection_names)
    {        
        
        if ( Check-Collection-Exists -collectionName $collectionName )
        { 
            if ( Delete-Collection -collectionName $collectionName -deleteConfig $false )
            {
                Write-Host "Collection $collectionName deleted successfully" -ForegroundColor Green
            }
            else
            {
                Write-Error "Error deleting collection $collectionName"
                return
            }
        }
        else { Write-Verbose "Collection $collectionName did not exist already" }

        
        # Solr checks if the collection already exists
        #if ( -n Check-Collection-Exist -collectionName $collectionName )
        #{
        #    Create-Collection -collectionName $collectionName -confdir "sitecoreconf" -
        #}
    }
    Write-Host "Finished deleting Sitecore collections" -ForegroundColor Green
}



if ( $command -eq "create" )
{   
   Create-Sitecore-Collections
}
if ( $command -eq "delete" )
{
   Delete-Sitecore-Collections
}


