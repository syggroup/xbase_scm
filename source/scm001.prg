#include "scm.ch"

***************************
Function Configura_Servidor
***************************
PRIVATE oJanela
PRIVATE oFont
PRIVATE aItens  :={"POSTGRESQL"}

PRIVATE oTIPO_SQL
PRIVATE oHOST
PRIVATE oPORTA
PRIVATE oDATABASE
PRIVATE oUSUARIO
PRIVATE oSENHA
PRIVATE oCHARSET

PRIVATE vTIPO_SQL:=aItens[1]
PRIVATE vHOST    :=""
PRIVATE vPORTA   :=""
PRIVATE vDATABASE:=""
PRIVATE vUSUARIO :=""
PRIVATE vSENHA   :=""
PRIVATE vCHARSET :=""

IF Use_Arq("SYGECOM",,.T.,.F.,.T.)=.F.  // COMPARTILHADO
   MsgStop("Erro ao Abrir as Configura��es do sistema, Favor Revisar","Aviso do Sistema")
   SAIR2()
   Return
ENDIF

SELE SYGECOM
IF LASTREC() > 0
   dbgotop()
   vTIPO_SQL=ALLTRIM(TIPO_SQL)
   vHOST    =ALLTRIM(HOST)
   vPORTA   =ALLTRIM(PORTA)
   vDATABASE=ALLTRIM(DATABASE)
   vCHARSET =ALLTRIM(CHARSET)

   vREG1=alltrim(USUARIO)
   vUSUARIO=HB_Decrypt( vREG1, eKEY )

   vREG2=alltrim(SENHA)
   vSENHA=HB_Decrypt( vREG2, eKEY )
ELSE
   AppRede()
   Replace TIPO_SQL with vTIPO_SQL
   LIBERAREG()
   dbcommit()
ENDIF

SetToolTipBalloon(.t.)
SetColorinFocus( .t. )

PREPARE FONT oFont NAME "Arial" WIDTH 0 HEIGHT -12 WEIGHT 400
INIT DIALOG oJanela CLIPPER NOEXIT TITLE "Configura��o de Conex�o com Servidor";
AT 0,0 SIZE 600,280;
ICON HIcon():AddResource(1004) ;
FONT oFont ;
STYLE DS_CENTER + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

@ 5,5 GROUPBOX grpConfiguracao        CAPTION "Configura��o de Conex�o com Servidor" SIZE 590,225;
COLOR 16711680

@ 31 ,42  SAY LINICIAR CAPTION "Tipo de Banco:" SIZE 100,22
@ 120,40 GET COMBOBOX oTIPO_SQL VAR vTIPO_SQL ITEMS aItens SIZE 150,24 TEXT;
ON CHANGE { || Atualiza_porta(vTIPO_SQL) };
VALID { || Atualiza_porta(vTIPO_SQL) };
TOOLTIP 'Selecione Aqui o Tipo de Banco de Dados'

@ 320,42  SAY LINICIAR CAPTION "Porta de Conex�o:" SIZE 100,22
@ 434,40 GET oPORTA VAR vPORTA SIZE 100,24;
STYLE ES_AUTOHSCROLL PICTURE '99999';
TOOLTIP 'Informe a porta de Conex�o com o Banco de dados'

@ 15 ,72  SAY LINICIAR CAPTION "Host de Conex�o:" SIZE 100,22
@ 120,70 GET oHOST VAR vHOST SIZE 415,24;
STYLE ES_AUTOHSCROLL MAXLENGTH 60;
TOOLTIP 'Informe o Host ou IP de Conex�o com o Banco de dados'

@ 27 ,102 SAY LINICIAR CAPTION "Base de dados:" SIZE 100,22
@ 120,100 GET oDATABASE VAR vDATABASE SIZE 415,24;
STYLE ES_AUTOHSCROLL MAXLENGTH 40;
TOOLTIP 'Informe o nome do banco de dados'

@ 62 ,132 SAY LINICIAR CAPTION "Usuario:" SIZE 100,22
@ 120,130 GET oUSUARIO VAR vUSUARIO SIZE 150,24;
STYLE ES_AUTOHSCROLL MAXLENGTH 30;
TOOLTIP 'Informe o usuario para a conex�o'

@ 330,132 SAY LINICIAR CAPTION "Senha:" SIZE 100,22
@ 385,130 GET oSENHA VAR vSENHA SIZE 150,24 PASSWORD;
STYLE ES_AUTOHSCROLL MAXLENGTH 30;
TOOLTIP 'Informe a senha do usuario'

@ 64 ,162 SAY LINICIAR CAPTION "CharSet:" SIZE 100,22
@ 120,160 GET oCHARSET VAR vCHARSET SIZE 150,24;
STYLE ES_AUTOHSCROLL MAXLENGTH 15;
TOOLTIP 'Informe o Ecoding ou Charset de conex�o'

@ 385,235 BUTTONEX oButton1 CAPTION "&Salvar" SIZE 100, 38 ;
BITMAP (HBitmap():AddResource(1006)):handle  ;
BSTYLE 0;
TOOLTIP "Salvar a sele��o de Impressora de Cheque";
ON CLICK {||  Salva_dados_sql() };
STYLE WS_TABSTOP

@ 495,235 BUTTONEX oButton2 CAPTION "&Cancelar" SIZE 100,38 ;
BITMAP (HBitmap():AddResource(1005)):handle  ;
BSTYLE 0;
TOOLTIP "Sair e Voltar ao Menu";
ON CLICK {|| oJanela:Close() };
STYLE WS_TABSTOP

oJanela:Activate()

RETURN nil

************************
Function Salva_dados_sql
************************
IF EMPTY(vHOST)
   MsgInfo("Obrigatorio informar o Host de conex�o, Favor revisar","Aviso do Sistema")
   oHOST:setfocus()
 	 RETURN
ENDIF

IF EMPTY(vDATABASE)
   MsgInfo("Obrigatorio informar o Banco de dados de Acesso, Favor revisar","Aviso do Sistema")
   oDATABASE:setfocus()
 	 RETURN
ENDIF

IF EMPTY(vUSUARIO)
   MsgInfo("Obrigatorio informar o Usuario de Acesso, Favor revisar","Aviso do Sistema")
   oUSUARIO:setfocus()
 	 RETURN
ENDIF

IF EMPTY(vSENHA)
   MsgInfo("Obrigatorio informar a Senha do Usuario, Favor revisar","Aviso do Sistema")
   oSENHA:setfocus()
 	 RETURN
ENDIF

vUSUARIO=alltrim(vUSUARIO)
vSENHA=alltrim(vSENHA)

SELE SYGECOM
dbgotop()
TRAVAREG("S")
Replace TIPO_SQL WITH ALLTRIM(vTIPO_SQL),;
HOST             WITH ALLTRIM(vHOST),;
PORTA            WITH vPORTA,;
DATABASE         WITH vDATABASE,;
USUARIO          WITH HB_Crypt( vUSUARIO, eKEY ),;
SENHA            WITH HB_Crypt( vSENHA, eKEY ),;
CHARSET          WITH vCHARSET
DBCOMMIT()
LIBERAREG()

MsgInfo("Informa��es salvas com sucesso, Para usar essas configura��es voc� tem que fechar e abrir o sistema novamente","Aviso do Sistema")

oJanela:Close()
RETURN

***************************
Function Atualiza_porta(vP)
***************************
IF vP="MYSQL"
   vPORTA="3306"
ELSEIF vP="POSTGRESQL"
   vPORTA="5432"
ELSEIF vP="FIREBIRD"
   vPORTA="3050"
ELSEIF vP="ORACLE"
   vPORTA="1521"
ENDIF
oPORTA:SetText( vPORTA )
oPORTA:Refresh()
Return(.T.)
