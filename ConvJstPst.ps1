######################################################
# JST PST 変換
######################################################
Param([string]$YYYYMMDD, [string]$HHMMSS, [switch]$ToJST, [switch]$ToPST)

# タイムゾーン
if((Get-Command Get-TimeZone -ErrorAction SilentlyContinue) -eq $null){
	echo "[FAIL] このバージョンでは Get-TimeZone コマンドレットがサポートされていません"
	exit
}
$C_JstTimeZone = Get-TimeZone -Id "Tokyo Standard Time"
$C_PstTimeZone = Get-TimeZone -Id "Pacific Standard Time"

# 時差
$C_BaseJstOffset = $C_JstTimeZone.BaseUtcOffset.Hours
$C_BasePstOffset = $C_PstTimeZone.BaseUtcOffset.Hours

# Base 時差
$C_BaseLagJst2Pst = ($C_BaseJstOffset * -1) + $C_BasePstOffset
$C_BaseLagPst2Jst = $C_BaseLagJst2Pst * -1

######################################################
# JST to PST
######################################################
function CalcJst2PstLocalTime($DateTime){

	# 指定日時の JST 時差
	$JstLocalTimeOffset = ($C_JstTimeZone.GetUtcOffset($DateTime)).Hours

	# 指定日時の PST 時差
	$BasePstTime = $DateTime.AddHours($C_BaseLagJst2Pst)
	$PstLocalTimeOffset = ($C_PstTimeZone.GetUtcOffset($BasePstTime)).Hours

	# サマータイムを考慮した時差
	$LocalLagJst2Pst = ($JstLocalTimeOffset * -1) + $PstLocalTimeOffset

	# 指定日時の PST 日時
	$LocalPST = $DateTime.AddHours($LocalLagJst2Pst)

	return $LocalPST
}

######################################################
# PST to JST
######################################################
function CalcPst2JstLocalTime($DateTime){
	# 指定日時の Pst 時差
	$PstLocalTimeOffset = ($C_PstTimeZone.GetUtcOffset($DateTime)).Hours

	# 指定日時の Jst 時差
	$BaseJstTime = $DateTime.AddHours($C_BaseLagPst2Jst)
	$JstLocalTimeOffset = ($C_JstTimeZone.GetUtcOffset($BaseJstTime)).Hours

	# サマータイムを考慮した時差
	$LocalLagPst2Jst = ($PstLocalTimeOffset * -1) + $JstLocalTimeOffset

	# 指定日時の Jst 日時
	$LocalJst = $DateTime.AddHours($LocalLagPst2Jst)

	return $LocalJst
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

