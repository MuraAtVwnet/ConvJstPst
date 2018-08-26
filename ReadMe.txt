■ これは何?
JST と PST の相互変換 PowerShell スクリプトです

■ 使い方
ConvJstPst.ps1 YYYY/MM/DD HH:MM:SS [ -ToJST | -ToPST ]

■ 制限
PowerShell 5 以降
サマータイム切り替えタイミングの閾値タイミングで時刻ズレが起きます
(コード bug ではなく、.NET の仕様のような気がする)

■ Web Page
PST/PDT/UTCからJST変換表
http://www.vwnet.jp/windows/PST2JST/PST2JST.htm
