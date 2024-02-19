/*
 * $Id: errorsys.prg,v 1.11 2008/11/24 10:02:12 mlacecilia Exp $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * Windows errorsys replacement
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "scm.ch"

STATIC LogInitialPath := ""  //Curdrive()+ ":\" + rtrim(curdir())+ "\erros\"

#IfnDef __XHARBOUR__
   PROCEDURE hwg_ErrSys
      
      ErrorBlock( { | oError | SYG_DefError( oError ) } )

   RETURN
#else

PROCEDURE ErrorSys

   ErrorBlock( { | oError | SYG_DefError( oError ) } )

   RETURN
#endif

FUNCTION SYG_DefError( oError )
   LOCAL cMessage
   LOCAL cDOSError

   LOCAL n

   // By default, division by zero results in zero
   IF oError:genCode == EG_ZERODIV
      RETURN 0
   ENDIF

   // Set NetErr() of there was a database open error
   IF oError:genCode == EG_OPEN .AND. ;
      oError:osCode == 32 .AND. ;
      oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

*   IF oError:genCode == EG_READONLY  // TENTOU GRAVAR EM UMA TABELA QUE É SOMENTE LEITURA
*   ENDIF

   // Set NetErr() if there was a lock error on dbAppend()
   IF oError:genCode == EG_APPENDLOCK .AND. ;
      oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

   IF oError:genCode == EG_NOALIAS  // NÃO ACHOU O ALIAS ENTÃO ABRE O BANCO COMPARTILHADO
      Dirchange(Substr(Nomeexecutavel(.t.),1,(len(Nomeexecutavel(.t.))- len(Nomeexecutavel()))-1 ))  // caso esteja no meio de uma navegação que mudou o path do sistema.
      cALIAS :=oError:operation
      IF Use_Arq(cALIAS,oError:operation,.T.,.F.,.F.,.T.)=.T.
         RETURN .T.
      ENDIF
   ENDIF

*   IF oError:genCode == EG_NOORDER  // NÃO EXISTE A ORDEM
*      RETURN .T.
*   ENDIF
   #ifdef _XHBSQL_
   IF eTipo_banco="SQL"
      IF SR_CheckCnn() = .T.     // VEREFICA SE ESTA ATIVA A CONEXÃO
         FOR nI := 1 TO SR_TransactionCount()
             SR_rollbacktransaction()
         NEXT
         SR_EndTransaction()
      ENDIF
   ENDIF
   #endif

   cMessage := ErrorMessage( oError )
   IF ! Empty( oError:osCode )
      cDOSError := "(DOS Error " + LTrim( Str( oError:osCode ) ) + ")"
   ENDIF

   IF ! Empty( oError:osCode )
      cMessage += " " + cDOSError
   ENDIF

   n := 2
   WHILE ! Empty( ProcName( n ) )
      cMessage += Chr( 13 ) + Chr( 10 ) + "Called from " + ProcFile( n ) + "->" + ProcName( n ) + "(" + AllTrim( Str( ProcLine( n ++ ) ) ) + ")"
   ENDDO

   //included aditional informations

   cMessage += Chr( 13 ) + Chr( 10 )

   cMessage += Chr( 13 ) + Chr( 10 ) + 'Data e Hora........: ' + dtoc( date() ) + " - " + time()
   //cMessage += Chr( 13 ) + Chr( 10 ) + 'Empresa............: ' + xEMP
   //cMessage += Chr( 13 ) + Chr( 10 ) + 'Sistema/Atualizacao: ' + VERSAOATUAL
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Nome do Executavel.: ' + hb_cmdargargv()
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Nome do Micro......: ' + netname() + " - Nome Usuario.: "+ netname(.t.)
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Memoria Disponivel.: ' + alltrim(str( Memory(0) ))
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Pasta de Diretorio.: ' + curdrive()+":\"+rtrim(curdir())
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Sistema Operacional: ' + os()
   cMessage += Chr( 13 ) + Chr( 10 ) + 'Versão xHarbour....: ' + hwg_version( 1 )

   cLogFile := DTOS(DATE())+StrTran( TIME(), ":", "_")+".log"

   MemoWrit( LogInitialPath + cLogFile, cMessage )

   Dbcloseall()
   //Fecha_Janelas()
   
   ErrorPreview( cMessage, cLogFile )
   SAIR2()
RETURN .T.

FUNCTION ErrorMessage( oError )
   LOCAL cMessage

   // start error message
   cMessage := IIf( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

   // add subsystem name if available
   IF ISCHARACTER( oError:subsystem )
      cMessage += oError:subsystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code if available
   IF ISNUMBER( oError:subCode )
      cMessage += "/" + LTrim( Str( oError:subCode ) )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description if available
   IF ISCHARACTER( oError:description )
      cMessage += "  " + oError:description
   ENDIF

   // add either filename or operation
   DO CASE
   CASE ! Empty( oError:filename )
      cMessage += ": " + oError:filename
   CASE ! Empty( oError:operation )
      cMessage += ": " + oError:operation
   ENDCASE

   RETURN cMessage

FUNCTION hwg_WriteLog( cText, fname )
   LOCAL nHand

   fname := LogInitialPath + IIf( fname == Nil, "a.log", fname )
   IF ! File( fname )
      nHand := FCreate( fname )
   ELSE
      nHand := FOpen( fname, 1 )
   ENDIF
   FSeek( nHand, 0, 2 )
   FWrite( nHand, cText + Chr( 10 ) )
   FClose( nHand )

   RETURN nil

STATIC FUNCTION ErrorPreview( cMess, cArq )
   LOCAL oDlg, oEdit

   INIT DIALOG oDlg TITLE "Erro No Sistema SCM Vs. " + GETFILEVERSIONINFO() ;
   ICON HIcon():AddResource(1004)  ;
   AT 0,0 SIZE 500,500 ;
   FONT HFont():Add( '',0,-13,400,,,) CLIPPER  NOEXIT NOEXITESC NOCLOSABLE;
   STYLE DS_CENTER +WS_VISIBLE

   @ 10, 10 EDITBOX oEdit CAPTION cMess SIZE 480, 400 STYLE WS_VSCROLL + WS_HSCROLL + ES_MULTILINE + ES_READONLY ;
   COLOR 255 ;
   FONT HFont():Add( '',0,-11,400,,,);
   ON GETFOCUS { || SendMessage( oEdit:handle, EM_SETSEL, 0, 0 ) }
   
   @ 390,420 BUTTONEX "&Fechar" ON CLICK { || EndDialog_err() } SIZE 100, 38 ;
   BITMAP (HBitmap():AddResource(1005)):handle  ;
   TOOLTIP 'Clique aqui para Fechar';
   STYLE WS_TABSTOP
   
   oDlg:Activate()
RETURN Nil

*****************************
Static Function EndDialog_err
*****************************
SAIR2()
PostQuitMessage( 0 )
__quit()
RETURN Nil
