#include "hbblat.ch"
#include "common.ch"
#include "hwgui.ch"

FUNCTION Main( cFILE )
LOCAL nRet
LOCAL oBlat := HBBlat():New()
Local aFiles := {}

IF !FILE(cFILE)
   Return
ENDIF
TRY
   USE (cFILE) ALIAS EMAIL READONLY
catch e
   RETURN
END
SELE EMAIL
DBGOTOP()
cServer=ALLTRIM(SERVER)
nPort=PORTA
ccFrom=ALLTRIM(FROM)
aTo=ALLTRIM(ATO)
aCC=ALLTRIM(ACC)
aBCC=ALLTRIM(ABCC)
ccBody=ALLTRIM(MSG)
cSubject=ALLTRIM(SUBJECT)
cUser=ALLTRIM(USER)
cPass=ALLTRIM(PASS)
WUSUARIO=ALLTRIM(USUARIO)
wCONF=CONF
wMOSTRA=MOSTRA

DBGOTOP()
DO WHILE .NOT. EOF()
   cANEXOS=FILES

   IF !EMPTY(cANEXOS)
      AADD(aFiles, alltrim(cANEXOS))
   ENDIF
   
   SELE EMAIL
   DBSKIP()
ENDDO
DBCLOSEALL()
FERASE(cFILE)

IF cServer=Nil .OR. nPort=Nil .OR. ccFrom=Nil .OR. aTo=Nil .OR. aCC=Nil
   Return
ENDIF

WITH OBJECT oBlat
   :cFrom                   := ccFrom
   :cTo                     := aTo
   :cUserAUTH               := cUser
   :cPasswordAUTH           := cPass
   //:cUserPOP3               := cUser
   :cHostname               := cServer  //WUSUARIO
   if !EMPTY(aCC)
     :cCC                   := aCC   // com copia
   endif
   if !EMPTY(aBCC)
      :cBCC                  := aBCC  // com copia oculta
   endif
   //:cServerPOP3             := cServer  // servidor SMTP
   :cServerSMTP             := cServer  // servidor SMTP
   :nPortSMTP               := nPort    // porta do servidor SMTP
   :cSubject                := cSubject // asunto da mensagem
   :cBody                   := ccBody   // corpo da mensagem
   IF wCONF=.T.
      :lRequestReturnReceipt:= TRUE
      :lRequestDisposition  := TRUE   // confirmação de leitura
   ENDIF
   //:lRequestReturnReceipt   := TRUE   //
   IF len(aFiles) > 0
      :aAttachBinFiles      := aFiles   // arquivos anexos
   ENDIF
   IF wMOSTRA=.T.
      :cLogFile             := "log_email.txt"  // habilita um LOG
   ENDIF
   //:lDebug                := TRUE     // habilita o debug
   //:lLogOverwrite         := TRUE     // quando o LOG é usado deve sobre-escrever no arquivo LOG
END
nRet := oBlat:Send()
IF wMOSTRA=.T.
   if nRet # 0
      _newalert("Ocorreu o Seguinte Erro ao Tentar Enviar o Email: " +oBlat:BlatErrorString() ,"Aviso do Sistema")
   ELSE
      ferase("log_email.txt")
      _newalert("Email Enviado com Sucesso","Aviso do Sistema")
   endif
ENDIF
Return

*************************************
Function _newalert(cmensagem,ctitulo)
*************************************
PRIVATE oAlert, oEdtMensagem

INIT DIALOG oAlert  TITLE ctitulo ;
AT 0,0 SIZE 400,100 ;
STYLE DS_CENTER+WS_CAPTION+WS_POPUP ;
ON GETFOCUS {||mensagem(cMensagem),oAlert:close()};
ON INIT     {|O| FormInit(oAlert)};
COLOR RGB(255,255,255)

ACTIVATE DIALOG oAlert NOMODAL
oAlert:close()

RETURN Nil
**************************
STATIC FUNCTION visualizar
**************************
PARA nAcao
LOCAL nInicio, nFim, nStep, nLoop1
nInicio := IIF(nAcao = 1, 10,255)
nFim    := IIF(nAcao = 1, 255,0)
nStep   := IIF(nAcao = 1, 10,-10)
FOR nloop1 = nInicio TO nFim STEP nStep
    MilliSec(50)
    SetLayeredWindowAttributes(oAlert:handle, nloop1) //0,nloop1, 2)
NEXT
RETURN Nil

************************
STATIC FUNCTION mensagem
************************
PARA cmensagem
oAlert:show() //thisform.Visible=.t.
SetLayeredWindowAttributes(oAlert:handle, 10) //0, 10, 2)

@ 5,30 SAY oEdtMensagem CAPTION cmensagem SIZE oalert:nwidth,oalert:nheight;
      BACKCOLOR Rgb(255, 255, 255);
      FONT HFont():Add( 'Verdana',0,-11,400,,,)  ;
      COLOR RGB(32,32,32)    ;
      STYLE ES_CENTER
  visualizar(1)
  MilliSec(1000)
  visualizar(0)
  SetLayeredWindowAttributes(oAlert:handle, 0) //, 0, 2)
  oAlert:hide()
RETURN NIL

STATIC FUNCTION FormInit
#define WS_EX_LAYERED  524288
private oldstyle,newstyle
oAlert:hide()
oldstyle = HWG_GetWindowexSTYLE(oAlert:hANDLE)
NEWSTYLE = Hwg_BitOR( OLDstyle,WS_EX_LAYERED+WS_EX_TRANSPARENT)
HWG_SETWINDOWEXSTYLE(oAlert:hANDLE, NEWstyle)
moveWINDOW(oalert:handle,,)
SetLayeredWindowAttributes(oAlert:handle, 0) //, 0, 2)
SETTOPMOST(oAlert:Handle)
RETURN NIL

#define DC_CALL_STD 0x0020
STATIC Function SetLayeredWindowAttributes
parameters hwnd,ntransp
Private nResult
#define LWA_COLORKEY 0x1
#define LWA_ALPHA 0x2
nResult := DllCall("user32.dll" ,  DC_CALL_STD , "SetLayeredWindowAttributes" , hwnd,0 , ntransp,LWA_ALPHA )
RETURN NIL
