unit WordSpeller;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
    Windows, ExodusCOM_TLB, Word2000, ChatSpeller,
    Classes, ComObj, ActiveX, ExodusWordSpeller_TLB, StdVcl;

type
  TWordSpeller = class(TAutoObject, IWordSpeller, IExodusPlugin)
  protected
    procedure Startup(const ExodusController: IExodusController); safecall;
    procedure Shutdown; safecall;
    procedure Process(const xpath: WideString; const event: WideString; const xml: WideString); safecall;
    procedure NewChat(const jid: WideString; const Chat: IExodusChat); safecall;
    procedure NewRoom(const jid: WideString; const Room: IExodusChat); safecall;
    procedure menuClick(const ID: WideString); safecall;
    function onInstantMsg(const Body: WideString; const Subject: WideString): WideString; safecall;
    procedure Configure; safecall;
    { Protected declarations }
  private
    _exodus: IExodusController;
    _word: TWordApplication;
  end;

implementation

uses
    Dialogs, SysUtils, ComServ;

procedure TWordSpeller.Startup(const ExodusController: IExodusController);
var
    msg: string;
begin
    // exodus is starting up...
    _exodus := ExodusController;

    // init the word instance for the plugin
    try
        _word := TWordApplication.Create(nil);
        _word.Connect();
        _word.CheckSpelling('hello');
    except
        on E: Exception do begin
            msg := 'An Exception occurred while trying to start the WordSpeller plugin. (';
            msg := msg + E.Message + ')';
            MessageDlg(msg, mtError, [mbOK], 0);
        end;
    end;
end;

procedure TWordSpeller.Shutdown;
begin
    // exodus is shutting down... do cleanup
    OutputDebugString('WORDPLUGIN - SHUTDOWN');
    _word.Disconnect();
    _word.Free();
    _word := nil;
end;

procedure TWordSpeller.NewChat(const JID: WideString; Const Chat: IExodusChat);
var
    cp: TChatSpeller;
    chat_com: IExodusChat;
begin
    // a new chat window is firing up
    chat_com := IUnknown(Chat) as IExodusChat;
    cp := TChatSpeller.Create(_word, chat_com);
    cp.ObjAddRef();
    cp.reg_id := chat_com.RegisterPlugin(IExodusChatPlugin(cp));
end;

procedure TWordSpeller.NewRoom(const JID: WideString; Const Room: IExodusChat);
begin
    // a new TC Room is firing up
end;

procedure TWordSpeller.Process(const xpath: WideString;
    const event: WideString; const xml: WideString);
begin
    // we are getting some kind of Packet from a callback
end;

procedure TWordSpeller.menuClick(const ID: WideString);
begin
    //
end;

function TWordSpeller.onInstantMsg(const Body: WideString;
    const Subject: WideString): WideString;
begin
    //
end;

procedure TWordSpeller.Configure;
begin
    //
end;


initialization
  TAutoObjectFactory.Create(ComServer, TWordSpeller, Class_WordSpeller,
    ciMultiInstance, tmApartment);
end.
