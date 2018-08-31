######################################################
# JST PST 変換
######################################################
Param([string]$YYYYMMDD, [string]$HHMMSS, [switch]$ToJST, [switch]$ToPST)

# タイムゾーン
#if((Get-Command Get-TimeZone -ErrorAction SilentlyContinue) -eq $null){
#	echo "[FAIL] このバージョンでは Get-TimeZone コマンドレットがサポートされていません"
#	exit
#}
$C_PST_ZoneID = "Pacific Standard Time"
$C_JST_ZoneID = "Tokyo Standard Time"

######################################################
# JST to PST
######################################################
function CalcJst2PstLocalTime([datetime]$DateTime){
	[TimeSpan]$Offset = ([System.TimeZoneInfo]::FindSystemTimeZoneById($C_JST_ZoneID)).GetUtcOffset($DateTime)
	[datetimeoffset]$Jst = New-Object DateTimeOffset( $DateTime, $Offset )

	$JstTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($C_JST_ZoneID)
	if( $JstTimeZone.IsInvalidTime( $Jst.DateTime)){
		echo "[ERROR] $DateTime (JST) はサマータイム開始時のため存在しない時刻です"
		exit
	}

	[datetimeoffset]$Pst = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($Jst, $C_PST_ZoneID)

	$ReturnData = New-Object PSObject | Select-Object LocalTime, SummerTime
	$ReturnData.LocalTime = $Pst.DateTime

	$PstTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($C_PST_ZoneID)
	$ReturnData.SummerTime = $PstTimeZone.IsDaylightSavingTime($Pst.DateTime)

	return $ReturnData
}

######################################################
# PST to JST
######################################################
function CalcPst2JstLocalTime([datetime]$DateTime){
	[TimeSpan]$Offset = ([System.TimeZoneInfo]::FindSystemTimeZoneById($C_PST_ZoneID)).GetUtcOffset($DateTime)
	[datetimeoffset]$Pst = New-Object DateTimeOffset( $DateTime, $Offset )

	$PstTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($C_PST_ZoneID)
	if( $PstTimeZone.IsInvalidTime( $Pst.DateTime)){
		echo "[ERROR] $DateTime (PST) はサマータイム開始時のため存在しない時刻です"
		exit
	}

	[datetimeoffset]$Jst = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($Pst, $C_JST_ZoneID)

	$ReturnData = New-Object PSObject | Select-Object LocalTime, SummerTime
	$ReturnData.LocalTime = $Jst.DateTime

	$JstTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($C_JST_ZoneID)
	$ReturnData.SummerTime = $JstTimeZone.IsDaylightSavingTime($Jst.DateTime)

	return $ReturnData

}

######################################################
# Main
######################################################

if(((-not $ToPST) -and (-not $ToJST)) -or`
	($ToPST -and $ToJST) -or`
	(($YYYYMMDD -eq [string]$null) -and ($HHMMSS -eq [string]$null))){
	echo "Usage..."
	echo "    ConvJstPst.ps1 YYYY/MM/DD HH:MM:SS [ -ToJST | -ToPST ]"
	exit
}

try{
	[datetime]$DateTime = $YYYYMMDD + " " + $HHMMSS
}
catch{
	echo "[FAIL] 日時指定が正しくありません : $YYYYMMDD $HHMMSS "
	exit
}

if( $ToPST ){
	$LocalTime = CalcJst2PstLocalTime $DateTime
}
else{
	$LocalTime = CalcPst2JstLocalTime $DateTime
}

echo $LocalTime

