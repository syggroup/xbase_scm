if exist scm_dbf.exe     del scm_dbf.exe
D:\devel\xharbour_bcc7\bin\xbuild scm_dbf.exe.xbp -Noerr
if exist scm_dbf.exe     start scm_dbf.exe
del scm_dbf.map
del scm_dbf.tds
del scm_dbf.exe.log
del trace.log
del error.log
del sqlerror.log
del xbuild.windows.ini