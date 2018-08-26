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

######################################################
# JST to PST
######################################################
function CalcJst2PstLocalTime($DateTime){

	# 指定日時の JST 時差
	$JstLocalTimeOffset = ($C_JstTimeZone.GetUtcOffset($DateTime)).Hours

	# UTC
	$UTC = $DateTime.AddHours($JstLocalTimeOffset * -1)

	# PST Base 時間
	$BasePstTime = $UTC.AddHours($C_BasePstOffset)

	# PST 時間 の時差
	$PstLocalTimeOffset = ($C_PstTimeZone.GetUtcOffset($BasePstTime)).Hours

	# PST 時間
	$LocalPST = $UTC.AddHours($PstLocalTimeOffset)

	# 戻り値
	$ReturnData = New-Object PSObject | Select-Object LocalTime, SummerTime

	# ローカル時間
	$ReturnData.LocalTime = $LocalPST

	# 夏時間か
	$ReturnData.SummerTime = $C_PstTimeZone.IsDaylightSavingTime($BasePstTime)

	return $ReturnData
}

######################################################
# PST to JST
######################################################
function CalcPst2JstLocalTime($DateTime){

	# 指定日時の Pst 時差
	$PstLocalTimeOffset = ($C_PstTimeZone.GetUtcOffset($DateTime)).Hours

	# UTC
	$UTC = $DateTime.AddHours($PstLocalTimeOffset * -1)

	# Jst Base 時間
	$BaseJstTime = $UTC.AddHours($C_BaseJstOffset)

	# Jst 時間 の時差
	$JstLocalTimeOffset = ($C_JstTimeZone.GetUtcOffset($BaseJstTime)).Hours

	# Jst 時間
	$LocalJst = $UTC.AddHours($JstLocalTimeOffset)

	# 戻り値
	$ReturnData = New-Object PSObject | Select-Object LocalTime, SummerTime

	# ローカル時間
	$ReturnData.LocalTime = $LocalJst

	# 夏時間か
	$ReturnData.SummerTime = $C_JstTimeZone.IsDaylightSavingTime($BaseJstTime)

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

