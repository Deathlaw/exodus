{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R+,S-,T-,U-,V+,W+,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit AutoUpdate;
{
    Copyright 2002, Peter Millard

    This file is part of Exodus.

    Exodus is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Exodus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Exodus; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

interface

uses
  Classes,
  XMLTag;

type
  TNewUrlEvent = procedure(url: widestring);

  TAutoUpdateThread = class(TThread)
  private
    { Private declarations }
    _url : string;
    _last : TDateTime;
    _available : boolean;
    _background : boolean;
    _onNew : TNewUrlEvent;
    procedure checkDoUpdate();
  protected
    procedure Execute; override;
  public
    property URL : string read _url write _url;
    property Last : TDateTime read _last write _last;
    property Available : boolean read _available;
    property Background : boolean write _background;
    property OnNewUrl :  TNewUrlEvent write _onNew;
  end;

function InitAutoUpdate(background : boolean = true) : boolean;
procedure InitUpdateBranding();

const
    EXODUS_REG = '\Software\Jabber\Exodus';
    
implementation

uses
    AutoUpdateStatus,
    Controls,
    ExUtils,
    IdHttp,
    IQ,
    Dialogs,
    Forms,
    Registry,
    Session,
    ShellAPI,
    SysUtils,
    Windows,
    XMLUtils, PrefController;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
function InitAutoUpdate(background : boolean = true) : boolean;
var
    url  : string;
    last : TDateTime;
    t    : TAutoUpdateThread;
    reg  : TRegistry;
begin
    result := false;
    if (background and (not MainSession.Prefs.getBool('auto_updates'))) then exit;

    {$ifdef Win32}
    // If we have the magic reg key, this is the first time we've run this version,
    // with the new "save to session" logic.  Copy over the value, and keep going.
    // NOTE:  Take this out later, after everyone updates a couple of times.
    reg := TRegistry.Create();
    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.OpenKey(EXODUS_REG, true);
    url := reg.ReadString('Update_URL');
    if (url <> '') then begin
        MainSession.Prefs.setString('auto_update_url', url);
        reg.DeleteValue('Update_URL');
        end;
    {$endif}

    // NOTE: if you want to do auto-update, the easiest way to turn it on is
    // to create a branding.xml next to your exodus.exe, which contains this:
    // <brand>
    //   <auto_update_url>http://exodus.jabberstudio.org/daily/setup.exe</auto_update_url>
    // </brand>
    // TODO: add an edit box to the pref window?
    url  := MainSession.Prefs.getString('auto_update_url');
    try
        last := StrToDateTime(MainSession.Prefs.getString('last_update'));
    except
        on EConvertError do begin
            last := Now();
            MainSession.Prefs.setString('last_update', DateTimeToStr(last));
            end;
    end;

    t := TAutoUpdateThread.Create(true);
    t.URL := url;
    t.Last := last;
    t.Background := background;
    t.OnNewUrl := @ShowAutoUpdateStatus;
    if (background) then begin
        t.FreeOnTerminate := true;
        t.Resume();
        end
    else begin
        t.Execute();
        result := t.Available;
        end;
end;

procedure OnNewBrand(url : widestring);
var
    bfn : string;
    bfs : TFileStream;
    http : TIdHTTP;
begin
    bfn := ExtractFilePath(Application.EXEName) + 'branding.new';
    bfs := TFileStream.Create(bfn, fmOpenWrite or fmCreate);
    http := nil;
    try
      http := TIdHTTP.Create(nil);
      http.HandleRedirects := true;
      http.Get(url, bfs);
      bfs.Free();
      if (http.ResponseCode = 200) then begin
          DeleteFile(pchar(ExtractFilePath(Application.EXEName) + 'branding.xml'));
          RenameFile(bfn, 'branding.xml');
          MainSession.Prefs.setString('last_branding_update', DateTimeToStr(http.Response.LastModified));
          // Harumph.  There's no good way to reparse the branding file.  Even if
          // there was, there's no way to know where those prefs have been used
          // at this time.  Therefore, just wait patiently until the next time
          // the client starts up.
          end
      else
          DeleteFile(pchar(bfn));
    finally
        if (http <> nil) then http.Free();
      end;
end;

{---------------------------------------}
procedure InitUpdateBranding();
var
    url  : string;
    last : TDateTime;
    t    : TAutoUpdateThread;
begin
    url  := MainSession.Prefs.getString('branding_url');
    if (url = '') then exit;
    
    try
        last := StrToDateTime(MainSession.Prefs.getString('last_branding_update'));
    except
        on EConvertError do begin
            last := Now();
            MainSession.Prefs.setString('last_branding_update', DateTimeToStr(last));
            end;
    end;

    t := TAutoUpdateThread.Create(true);
    t.URL := url;
    t.Last := last;
    t.Background := true;
    t.OnNewUrl := @OnNewBrand;
    t.FreeOnTerminate := true;
    t.Resume();
end;

{---------------------------------------}
{---------------------------------------}
{ TAutoUpdateThread }
{---------------------------------------}
{---------------------------------------}
procedure TAutoUpdateThread.Execute;
var
    http : TIdHTTP;
begin
    _available := false;
    http := nil;
    try
        http := TIdHTTP.Create(nil);
        http.HandleRedirects := true;
        http.Head(_url);
        if (http.ResponseCode <> 200) then begin
            exit;
            end;

        if (http.Response.LastModified <= _last) then
            exit;
        if (Assigned(_onNew)) then begin
            if (_background) then
                synchronize(checkDoUpdate)
            else
                _onNew(_url);
            end;

        _available := true;
    finally
        if (http <> nil) then http.Free();
        end;
end;

{---------------------------------------}
procedure TAutoUpdateThread.checkDoUpdate();
begin
    _onNew(_url);
end;

end.
