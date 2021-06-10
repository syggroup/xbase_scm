if exist scm_sql_debug.exe     del scm_sql_debug.exe
D:\devel\xharbour_bcc7\bin\xbuild scm_sql_debug.exe.xbp -Noerr
if exist scm_sql_debug.exe  start D:\devel\xharbour_bcc7\bin\debug.exe scm_sql_debug.exe