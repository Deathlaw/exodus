unit ExTracer;
{
    Copyright 2004, Peter Millard

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, buttonFrame, StdCtrls;

{$ifdef TRACE_EXCEPTIONS}
type
  TfrmException = class(TForm)
    mmLog: TMemo;
    frameButtons1: TframeButtons;
    procedure frameButtons1btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmException: TfrmException;

procedure ExodusException(ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
{$endif}

implementation

{$R *.dfm}

{$ifdef TRACE_EXCEPTIONS}
uses
    ExResponders, Unicode, 
    IdException, JclDebug, JclHookExcept, TypInfo;

procedure ExodusException(ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
var
    e: Exception;
    l: TWidestringlist;
begin

    // ignore some exceptions
    e := Exception(ExceptObj);
    if (e is EConvertError) then exit;
    if (e is EIdSocketError) then exit;
    if (e is EIdClosedSocket) then exit;
    if (e is EIdDNSResolverError) then exit;
    if (e is EIdConnClosedGracefully) then exit;
    //if (e is EIdTerminateThreadTimeout) then exit;

    // Just use the existing error log stuff.
    l := TWidestringlist.Create();
    l.Add('Exception: ' + e.Message);
    ExHandleException(l);
end;

procedure TfrmException.frameButtons1btnCancelClick(Sender: TObject);
begin
    Self.Close();
end;

procedure TfrmException.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caHide;
end;

initialization
    frmException := nil;
    JclStackTrackingOptions := JclStackTrackingOptions + [stRawMode];
    JclStackTrackingOptions := JclStackTrackingOptions + [stExceptFrame];
    JclStackTrackingOptions := JclStackTrackingOptions + [stStaticModuleList];
    JclStartExceptionTracking;
    JclAddExceptNotifier(ExodusException);
{$endif}

end.
