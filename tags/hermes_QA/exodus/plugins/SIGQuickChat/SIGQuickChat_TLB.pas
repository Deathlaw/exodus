unit SIGQuickChat_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 12/1/2006 5:05:14 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\source\exodus\exodus\plugins\SIGQuickChat\SIGQuickChat.tlb (1)
// LIBID: {8D23F765-046D-41C2-B7F3-A923C98ECAD4}
// LCID: 0
// Helpfile: 
// HelpString: SIGQuickChat Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
//   (2) v1.0 Exodus, (C:\Program Files\Jabber Inc\Hermes\Hermes.exe)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Exodus_TLB, Graphics, OleCtrls, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SIGQuickChatMajorVersion = 1;
  SIGQuickChatMinorVersion = 0;

  LIBID_SIGQuickChat: TGUID = '{8D23F765-046D-41C2-B7F3-A923C98ECAD4}';

  IID_IActiveFormX: TGUID = '{88631E02-B2DD-4B36-8C72-D2B8451EFD19}';
  DIID_IActiveFormXEvents: TGUID = '{C85D2D27-F667-42A7-8075-6B6581713F44}';
  CLASS_ActiveFormX: TGUID = '{88E6C2AB-1781-41E5-8C97-D5FA27471403}';
  CLASS_SIGQuickChatPlugin: TGUID = '{155CAA4F-A52A-463F-81B9-7D93F0B23138}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxActiveFormBorderStyle
type
  TxActiveFormBorderStyle = TOleEnum;
const
  afbNone = $00000000;
  afbSingle = $00000001;
  afbSunken = $00000002;
  afbRaised = $00000003;

// Constants for enum TxPrintScale
type
  TxPrintScale = TOleEnum;
const
  poNone = $00000000;
  poProportional = $00000001;
  poPrintToFit = $00000002;

// Constants for enum TxMouseButton
type
  TxMouseButton = TOleEnum;
const
  mbLeft = $00000000;
  mbRight = $00000001;
  mbMiddle = $00000002;

// Constants for enum TxPopupMode
type
  TxPopupMode = TOleEnum;
const
  pmNone = $00000000;
  pmAuto = $00000001;
  pmExplicit = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IActiveFormX = interface;
  IActiveFormXDisp = dispinterface;
  IActiveFormXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ActiveFormX = IActiveFormX;
  SIGQuickChatPlugin = IExodusPlugin;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPUserType1 = ^IFontDisp; {*}


// *********************************************************************//
// Interface: IActiveFormX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {88631E02-B2DD-4B36-8C72-D2B8451EFD19}
// *********************************************************************//
  IActiveFormX = interface(IDispatch)
    ['{88631E02-B2DD-4B36-8C72-D2B8451EFD19}']
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Color: OLE_COLOR; safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    function Get_Font: IFontDisp; safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    procedure _Set_Font(var Value: IFontDisp); safecall;
    function Get_KeyPreview: WordBool; safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    function Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    function Get_Scaled: WordBool; safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    function Get_Active: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_PopupMode: TxPopupMode; safecall;
    procedure Set_PopupMode(Value: TxPopupMode); safecall;
    function Get_ScreenSnap: WordBool; safecall;
    procedure Set_ScreenSnap(Value: WordBool); safecall;
    function Get_SnapBuffer: Integer; safecall;
    procedure Set_SnapBuffer(Value: Integer); safecall;
    function Get_DockSite: WordBool; safecall;
    procedure Set_DockSite(Value: WordBool); safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_MouseInClient: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    function Get_UseDockManager: WordBool; safecall;
    procedure Set_UseDockManager(Value: WordBool); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_ExplicitLeft: Integer; safecall;
    function Get_ExplicitTop: Integer; safecall;
    function Get_ExplicitWidth: Integer; safecall;
    function Get_ExplicitHeight: Integer; safecall;
    function Get_AlignWithMargins: WordBool; safecall;
    procedure Set_AlignWithMargins(Value: WordBool); safecall;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property AutoScroll: WordBool read Get_AutoScroll write Set_AutoScroll;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property AxBorderStyle: TxActiveFormBorderStyle read Get_AxBorderStyle write Set_AxBorderStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Color: OLE_COLOR read Get_Color write Set_Color;
    property Font: IFontDisp read Get_Font write Set_Font;
    property KeyPreview: WordBool read Get_KeyPreview write Set_KeyPreview;
    property PixelsPerInch: Integer read Get_PixelsPerInch write Set_PixelsPerInch;
    property PrintScale: TxPrintScale read Get_PrintScale write Set_PrintScale;
    property Scaled: WordBool read Get_Scaled write Set_Scaled;
    property Active: WordBool read Get_Active;
    property DropTarget: WordBool read Get_DropTarget write Set_DropTarget;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property PopupMode: TxPopupMode read Get_PopupMode write Set_PopupMode;
    property ScreenSnap: WordBool read Get_ScreenSnap write Set_ScreenSnap;
    property SnapBuffer: Integer read Get_SnapBuffer write Set_SnapBuffer;
    property DockSite: WordBool read Get_DockSite write Set_DockSite;
    property DoubleBuffered: WordBool read Get_DoubleBuffered write Set_DoubleBuffered;
    property AlignDisabled: WordBool read Get_AlignDisabled;
    property MouseInClient: WordBool read Get_MouseInClient;
    property VisibleDockClientCount: Integer read Get_VisibleDockClientCount;
    property UseDockManager: WordBool read Get_UseDockManager write Set_UseDockManager;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property ExplicitLeft: Integer read Get_ExplicitLeft;
    property ExplicitTop: Integer read Get_ExplicitTop;
    property ExplicitWidth: Integer read Get_ExplicitWidth;
    property ExplicitHeight: Integer read Get_ExplicitHeight;
    property AlignWithMargins: WordBool read Get_AlignWithMargins write Set_AlignWithMargins;
  end;

// *********************************************************************//
// DispIntf:  IActiveFormXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {88631E02-B2DD-4B36-8C72-D2B8451EFD19}
// *********************************************************************//
  IActiveFormXDisp = dispinterface
    ['{88631E02-B2DD-4B36-8C72-D2B8451EFD19}']
    property Visible: WordBool dispid 201;
    property AutoScroll: WordBool dispid 202;
    property AutoSize: WordBool dispid 203;
    property AxBorderStyle: TxActiveFormBorderStyle dispid 204;
    property Caption: WideString dispid -518;
    property Color: OLE_COLOR dispid -501;
    property Font: IFontDisp dispid -512;
    property KeyPreview: WordBool dispid 205;
    property PixelsPerInch: Integer dispid 206;
    property PrintScale: TxPrintScale dispid 207;
    property Scaled: WordBool dispid 208;
    property Active: WordBool readonly dispid 209;
    property DropTarget: WordBool dispid 210;
    property HelpFile: WideString dispid 211;
    property PopupMode: TxPopupMode dispid 212;
    property ScreenSnap: WordBool dispid 213;
    property SnapBuffer: Integer dispid 214;
    property DockSite: WordBool dispid 215;
    property DoubleBuffered: WordBool dispid 216;
    property AlignDisabled: WordBool readonly dispid 217;
    property MouseInClient: WordBool readonly dispid 218;
    property VisibleDockClientCount: Integer readonly dispid 219;
    property UseDockManager: WordBool dispid 220;
    property Enabled: WordBool dispid -514;
    property ExplicitLeft: Integer readonly dispid 221;
    property ExplicitTop: Integer readonly dispid 222;
    property ExplicitWidth: Integer readonly dispid 223;
    property ExplicitHeight: Integer readonly dispid 224;
    property AlignWithMargins: WordBool dispid 225;
  end;

// *********************************************************************//
// DispIntf:  IActiveFormXEvents
// Flags:     (4096) Dispatchable
// GUID:      {C85D2D27-F667-42A7-8075-6B6581713F44}
// *********************************************************************//
  IActiveFormXEvents = dispinterface
    ['{C85D2D27-F667-42A7-8075-6B6581713F44}']
    procedure OnActivate; dispid 201;
    procedure OnClick; dispid 202;
    procedure OnCreate; dispid 203;
    procedure OnDblClick; dispid 204;
    procedure OnDestroy; dispid 205;
    procedure OnDeactivate; dispid 206;
    procedure OnKeyPress(var Key: Smallint); dispid 207;
    procedure OnMouseEnter; dispid 208;
    procedure OnMouseLeave; dispid 209;
    procedure OnPaint; dispid 210;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TActiveFormX
// Help String      : ActiveFormX Control
// Default Interface: IActiveFormX
// Def. Intf. DISP? : No
// Event   Interface: IActiveFormXEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TActiveFormXOnKeyPress = procedure(ASender: TObject; var Key: Smallint) of object;

  TActiveFormX = class(TOleControl)
  private
    FOnActivate: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnKeyPress: TActiveFormXOnKeyPress;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnPaint: TNotifyEvent;
    FIntf: IActiveFormX;
    function  GetControlInterface: IActiveFormX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    property  ControlInterface: IActiveFormX read GetControlInterface;
    property  DefaultInterface: IActiveFormX read GetControlInterface;
    property Visible: WordBool index 201 read GetWordBoolProp write SetWordBoolProp;
    property Active: WordBool index 209 read GetWordBoolProp;
    property DropTarget: WordBool index 210 read GetWordBoolProp write SetWordBoolProp;
    property HelpFile: WideString index 211 read GetWideStringProp write SetWideStringProp;
    property PopupMode: TOleEnum index 212 read GetTOleEnumProp write SetTOleEnumProp;
    property ScreenSnap: WordBool index 213 read GetWordBoolProp write SetWordBoolProp;
    property SnapBuffer: Integer index 214 read GetIntegerProp write SetIntegerProp;
    property DockSite: WordBool index 215 read GetWordBoolProp write SetWordBoolProp;
    property DoubleBuffered: WordBool index 216 read GetWordBoolProp write SetWordBoolProp;
    property AlignDisabled: WordBool index 217 read GetWordBoolProp;
    property MouseInClient: WordBool index 218 read GetWordBoolProp;
    property VisibleDockClientCount: Integer index 219 read GetIntegerProp;
    property UseDockManager: WordBool index 220 read GetWordBoolProp write SetWordBoolProp;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp;
    property ExplicitLeft: Integer index 221 read GetIntegerProp;
    property ExplicitTop: Integer index 222 read GetIntegerProp;
    property ExplicitWidth: Integer index 223 read GetIntegerProp;
    property ExplicitHeight: Integer index 224 read GetIntegerProp;
  published
    property Anchors;
    property  ParentColor;
    property  ParentFont;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property AutoScroll: WordBool index 202 read GetWordBoolProp write SetWordBoolProp stored False;
    property AutoSize: WordBool index 203 read GetWordBoolProp write SetWordBoolProp stored False;
    property AxBorderStyle: TOleEnum index 204 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Caption: WideString index -518 read GetWideStringProp write SetWideStringProp stored False;
    property Color: TColor index -501 read GetTColorProp write SetTColorProp stored False;
    property Font: TFont index -512 read GetTFontProp write SetTFontProp stored False;
    property KeyPreview: WordBool index 205 read GetWordBoolProp write SetWordBoolProp stored False;
    property PixelsPerInch: Integer index 206 read GetIntegerProp write SetIntegerProp stored False;
    property PrintScale: TOleEnum index 207 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Scaled: WordBool index 208 read GetWordBoolProp write SetWordBoolProp stored False;
    property AlignWithMargins: WordBool index 225 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnKeyPress: TActiveFormXOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

// *********************************************************************//
// The Class CoSIGQuickChatPlugin provides a Create and CreateRemote method to          
// create instances of the default interface IExodusPlugin exposed by              
// the CoClass SIGQuickChatPlugin. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSIGQuickChatPlugin = class
    class function Create: IExodusPlugin;
    class function CreateRemote(const MachineName: string): IExodusPlugin;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TActiveFormX.InitControlData;
const
  CEventDispIDs: array [0..9] of DWORD = (
    $000000C9, $000000CA, $000000CB, $000000CC, $000000CD, $000000CE,
    $000000CF, $000000D0, $000000D1, $000000D2);
  CTFontIDs: array [0..0] of DWORD = (
    $FFFFFE00);
  CControlData: TControlData2 = (
    ClassID: '{88E6C2AB-1781-41E5-8C97-D5FA27471403}';
    EventIID: '{C85D2D27-F667-42A7-8075-6B6581713F44}';
    EventCount: 10;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80070020*);
    Flags: $0000001D;
    Version: 401;
    FontCount: 1;
    FontIDs: @CTFontIDs);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnActivate) - Cardinal(Self);
end;

procedure TActiveFormX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IActiveFormX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TActiveFormX.GetControlInterface: IActiveFormX;
begin
  CreateControl;
  Result := FIntf;
end;

class function CoSIGQuickChatPlugin.Create: IExodusPlugin;
begin
  Result := CreateComObject(CLASS_SIGQuickChatPlugin) as IExodusPlugin;
end;

class function CoSIGQuickChatPlugin.CreateRemote(const MachineName: string): IExodusPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SIGQuickChatPlugin) as IExodusPlugin;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TActiveFormX]);
end;

end.
