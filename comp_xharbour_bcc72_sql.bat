if exist scm_sql.exe     del scm_sql.exe
D:\devel\xharbour_bcc7\bin\xbuild scm_sql.exe.xbp -Noerr
if exist scm_sql.exe     start scm_sql.exe
del scm_sql.map
del scm_sql.tds
del scm_sql.exe.log
del trace.log
del error.log
del sqlerror.log
del xbuild.windows.ini