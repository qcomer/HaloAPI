#Requires -Version 7
function Get-HaloTicketType {
    <#
        .SYNOPSIS
            Gets ticket types from the Halo API.
        .DESCRIPTION
            Retrieves ticket types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Ticket Type ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$TicketTypeID,
        # Show the count of tickets in the results.
        [Parameter( ParameterSetName = "Multi")]
        [switch]$ShowCounts,
        # Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = "Multi")]
        [ValidateSet(
            "reqs",
            "opps",
            "prjs"
        )]
        [string]$Domain,
        # Filter counts to a specific view ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("view_id0")]
        [int32]$ViewID,
        # Include inactive ticket types in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowInactive,
        # Filter by a specific client id.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("client_id")]
        [int32]$ClientID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails
    )
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'tickettypeid=' parameter by removing it from the set parameters.
    if ($TicketTypeID) {
        $Parameters.Remove("UserID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($TicketTypeID) {
            Write-Verbose "Running in single-ticket-type mode because '-TicketTypeID' was provided."
            $Resource = "api/tickettype/$TicketTypeID$QueryString"
        } else {
            Write-Verbose "Running in multi-ticket-type mode."
            $Resource = "api/tickettype$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $TicketTypeResults = Invoke-HaloRequest @RequestParams
        Return $TicketTypeResults
    } catch {
        Write-Error "Failed to get ticket types from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}