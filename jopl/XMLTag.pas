unit XMLTag;
{
    Copyright 2001, Peter Millard

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
    Unicode,
    XMLNode,
    XMLAttrib,
    XMLCData,
    LibXmlParser,
    Classes,
    Contnrs;

type
  {---------------------------------------}
  {          TXMLTag Main Class Def       }
  {---------------------------------------}
  TXMLTag = class;

  TXMLNodeList = class(TObjectList)
    end;

  TXMLTagList = class(TList)
    private
        function GetTag(index: integer): TXMLTag;
    public
        property Tags[index: integer]: TXMLTag read GetTag; default;
    end;

  TXMLTag = class(TXMLNode)
  private
    _AttrList: TAttrList;       // list of attributes
    _Children: TXMLNodeList; // list of nodes
    _ns: WideString;
  public
    pTag: TXMLTag;

    constructor Create; overload; override;
    constructor Create(tagname: WideString); reintroduce; overload; virtual;
    constructor Create(tag: TXMLTag); reintroduce; overload; virtual;
    constructor Create(tagname, CDATA: WideString); reintroduce; overload; virtual;
    destructor Destroy; override;

    function AddTag(tagname: WideString): TXMLTag;
    function AddBasicTag(tagname, cdata: WideString): TXMLTag;
    function AddCData(content: WideString): TXMLCData;

    function GetAttribute(key: WideString): WideString;
    procedure PutAttribute(key, value: WideString);

    function ChildTags: TXMLTagList;
    function QueryXPTags(path: WideString): TXMLTagList;
    function QueryXPTag(path: WideString): TXMLTag;
    function QueryXPData(path: WideString): WideString;
    function QueryTags(key: WideString): TXMLTagList;
    function GetFirstTag(key: WideString): TXMLTag;
    function GetBasicText(key: WideString): WideString;
    function TagExists(key: WideString): boolean;

    function Data: WideString;
    function Namespace: WideString;
    function xml: WideString; override;

    procedure ClearTags;
    procedure ClearCData;
    procedure RemoveTag(node: TXMLTag);
    procedure AssignTag(const xml: TXMLTag);

    property Attributes: TAttrList read _AttrList;
    property Nodes: TXMLNodeList read _Children;
  end;

  TXPMatch = class
  private
    _AttrList: TAttrList;       // list of attributes
    function GetAttrCount: integer;
  public
    tag_name: WideString;
    get_cdata: boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Parse(xps: WideString);
    procedure putAttribute(name, value: WideString);
    function getAttribute(i: integer): TAttr;

    property AttrCount: integer read GetAttrCount;
    property AttrList: TAttrList read _AttrList;
  end;

  TXPLite = class
  private
    Matches: TWideStringList;
    attr: WideString;
    value: WideString;
    function GetString: WideString;
    function checkTags(Tag: TXMLTag; match_idx: integer): TXMLTagList;
    function doCompare(tag: TXMLTag; start: integer): boolean;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure Parse(xps: Widestring);
    function Compare(Tag: TXMLTag): boolean;
    function Query(Tag: TXMLTag): WideString;
    function GetTags(tag: TXMLTag): TXMLTagList;

    property AsString: Widestring read GetString;
    property XPMatchList: TWideStringList read Matches;
  end;


implementation

uses
    XMLConstants,
    XMLUtils,
    SysUtils;

function TXMLTagList.GetTag(index: integer): TXMLTag;
begin
    if (index >= 0) and (index < Count) then
        Result := TXMLTag(Items[index])
    else
        Result := nil;
end;

{---------------------------------------}
{---------------------------------------}
{  TXMLTag  Class Implmenetation        }
{---------------------------------------}
{---------------------------------------}

constructor TXMLTag.Create;
begin
    // Create the object
    inherited;

    NodeType := xml_tag;
    _AttrList := TAttrList.Create();
    _Children := TXMLNodeList.Create(true);

    pTag := nil;
end;

{---------------------------------------}
constructor TXMLTag.Create(tagname: WideString);
begin
    //
    Create();
    Name := tagname;
end;

constructor TXMLTag.Create(tag: TXMLTag);
begin
    //
    Create();
    Self.AssignTag(tag);
end;

constructor TXMLTag.Create(tagname, CDATA: WideString);
begin
    Create(tagname);
    self.AddCData(CDATA);
end;

{---------------------------------------}
destructor TXMLTag.Destroy;
begin
    // Free everything for this node
    _AttrList.Free;
    _Children.Clear;
    _Children.Free;

    inherited Destroy;
end;

{---------------------------------------}
function TXMLTag.AddTag(tagname: WideString): TXMLTag;
var
    t: TXMLTag;
begin
    // Add a tag
    t := TXMLTag.Create;
    t.Name := tagname;
    t.pTag := Self;
    _Children.Add(t);
    Result := t;
end;

{---------------------------------------}
function TXMLTag.AddBasicTag(tagname, cdata: WideString): TXMLTag;
var
    t: TXMLTag;
begin
    t := AddTag(tagname);
    t.pTag := Self;
    t.AddCData(cdata);
    Result := t;
end;

{---------------------------------------}
procedure TXMLTag.ClearTags;
var
    i: integer;
    n: TXMLNode;
begin
    // clear out all child tags
    for i := _children.Count - 1 downto 0 do begin
        n := TXMLNode(_children[i]);
        if n is TXMLTag then
            _children.Delete(i);
        end;
end;

{---------------------------------------}
procedure TXMLTag.RemoveTag(node: TXMLTag);
var
    i: integer;
begin
    // remove this tag
    i := _Children.IndexOf(node);
    if (i >= 0) then
        _children.Delete(i);
end;

{---------------------------------------}
procedure TXMLTag.ClearCData;
var
    i: integer;
    n: TXMLNode;
begin
    // clear out all child tags that are CDATA
    for i := _children.Count - 1 downto 0 do begin
        n := TXMLNode(_children[i]);
        if n is TXMLCDATA then
            _children.Delete(i);
        end;
end;

{---------------------------------------}
function TXMLTag.AddCData(content: WideString): TXMLCData;
var
    c: TXMLCData;
begin
    // Add the CData to the tag
    c := TXMLCData.Create(content);
    _Children.Add(c);
    Result := c;
end;

{---------------------------------------}
function TXMLTag.GetAttribute(key: WideString): WideString;
var
    attr: TNvpNode;
begin
    // get the attribute
    Result := '';
    attr := _AttrList.Node(key);
    if attr <> nil then
        Result := attr.Value;
    end;

{---------------------------------------}
procedure TXMLTag.PutAttribute(key, value: WideString);
var
    a: TNvpNode;
begin
    // Setup an attribute key value pair
    a := _AttrList.Node(key);
    if a = nil then begin
        a := TAttr.Create(key, value);
        _AttrList.Add(a);
        end
    else
        a.value := value;

end;

{---------------------------------------}
function TXMLTag.QueryXPTags(path: WideString): TXMLTagList;
var
    xp: TXPLite;
begin
    // Return a tag list based on the xpath stuff
    xp := TXPLite.Create();
    xp.Parse(path);
    Result := xp.GetTags(Self);
    xp.Free;
end;

{---------------------------------------}
function TXMLTag.QueryXPTag(path: WideString): TXMLTag;
var
    tags: TXMLTagList;
begin
    // Return a tag based on the xpath stuff
    tags := QueryXPTags(path);
    if (tags.count <= 0) then
        Result := nil
    else
        Result := tags[0];
    tags.Free;
end;

{---------------------------------------}
function TXMLTag.QueryXPData(path: WideString): WideString;
var
    i: integer;
    spath, att: WideString;
    ftags: TXMLTagList;
    t: TXMLTag;
begin
    // Return a WideString based on the xpath stuff
    att := '';
    spath := path;
    Result := '';

    // check to see if we are getting an attribute "/foo/bar@attribute"
    i := length(path);
    while (i >= 1) do begin
        if (path[i] = '@') then begin
            att := Copy(path, i + 1, length(path) - i);
            spath := Copy(path, 1, i-1);
            break;
            end
        else if (path[i] = '/') then
            break;
        dec(i);
        end;

    if (att <> '') then begin
        t := Self.QueryXPTag(spath);
        Result := t.GetAttribute(att);
        end
    else begin
        ftags := Self.QueryXPTags(spath);
        for i := 0 to ftags.Count - 1 do
            Result := Result + ftags.tags[i].Data;
        end;
end;

{---------------------------------------}
function TXMLTag.ChildTags: TXMLTagList;
var
    t: TXMLTagList;
    n: TXMLNode;
    i: integer;
begin
    // return a list of all child elements
    t := TXMLTagList.Create();
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if (n.IsTag) then
            t.Add(TXMLTag(n));
        end;
    Result := t;
end;


{---------------------------------------}
function TXMLTag.QueryTags(key: WideString): TXMLTagList;
var
    t: TXMLTagList;
    n: TXMLNode;
    sname: WideString;
    i: integer;
begin
    // Return all of the immediate children which
    // have the specified tag name
    t := TXMLTagList.Create();
    sname := Trim(key);
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if ((n.IsTag) and (NameMatch(sname, n.name))) then
            t.Add(TXMLTag(n));
        end;

    Result := t;
end;

{---------------------------------------}
function TXMLTag.TagExists(key: WideString): boolean;
begin
    Result := (GetFirstTag(key) <> nil);
end;

{---------------------------------------}
function TXMLTag.GetFirstTag(key: WideString): TXMLTag;
var
    sname: WideString;
    i: integer;
    n: TXMLNode;
begin
    Result := nil;
    sname := Trim(key);
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if ((n.IsTag) and (NameMatch(sname, n.name))) then begin
            Result := TXMLTag(n);
            exit;
            end;
        end;
end;

{---------------------------------------}
function TXMLTag.GetBasicText(key: WideString): WideString;
var
    t: TXMLTag;
begin
    t := self.GetFirstTag(key);
    if (t <> nil) then
        Result := t.Data
    else
        Result := '';
end;

{---------------------------------------}
function TXMLTag.Data: WideString;
var
    i: integer;
    n: TXMLNode;
begin
    // add all CData together
    Result := '';
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if (n.NodeType = xml_CDATA) then begin
            Result := Result + TXMLCData(n).Data + ' ';
            break;
            end;
        end;
    if Result <> '' then Result := Trim(Result);
end;

{---------------------------------------}
function TXMLTag.Namespace: WideString;
var
    n:  TXMLNode;
    i:  integer;
begin
    // find the namespace for this tag
    if _ns = '' then begin
        _ns := Self.GetAttribute('xmlns');
        if _ns = '' then begin
            // check thru all the tag elements
            for i := 0 to _Children.Count - 1 do begin
                n := TXMLNode(_Children[i]);
                if (n.NodeType = xml_Tag) then begin
                    _ns := TXMLTag(n).GetAttribute('xmlns');
                    if _ns <> '' then
                        break;
                    end;
                end;
            end;
        end;
    Result := _ns;
end;

{---------------------------------------}
function TXMLTag.xml: WideString;
var
    i: integer;
    x: WideString;
begin
    // Return a WideString containing the full
    // representation of this tag
    x := '<' + Self.Name;
    for i := 0 to _AttrList.Count - 1 do
        x := x + ' ' + _AttrList.Name(i) + '="' + _AttrList.Value(i) + '"';

    if _Children.Count <= 0 then
        x := x + '/>'
    else begin
        // iterate over all the children
        x := x + '>';
        for i := 0 to _Children.Count - 1 do
            x := x + TXMLNode(_Children[i]).xml;
        x := x + '</' + Self.name + '>';
        end;
    Result := x;
end;

{---------------------------------------}
procedure TXMLTag.AssignTag(const xml: TXMLTag);
var
    i: integer;
    c: TXMLTag;
    tags: TXMLTagList;
begin
    // Make self contain all the info that xml does
    Self.Name := xml.Name;
    tags := xml.ChildTags();

    for i := 0 to tags.Count - 1 do begin
        c := Self.AddTag(tags[i].Name);
        c.AssignTag(tags[i]);
        end;

    tags.Free();

    Self.AddCData(xml.Data);

    for i := 0 to xml._AttrList.Count - 1 do
        Self.PutAttribute(xml._AttrList.Name(i), xml._AttrList.Value(i));
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
constructor TXPMatch.Create;
begin
    inherited;
    
    _AttrList := TAttrList.Create();
    tag_name := '';
    get_cdata := false;
end;

{---------------------------------------}
destructor TXPMatch.Destroy;
begin
    //
    _AttrList.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TXPMatch.putAttribute(name, value: WideString);
var
    pair: TAttr;
begin
    // specify an attribute on the tag.
    pair := TAttr.Create(name, value);
    _AttrList.Add(pair);
end;

{---------------------------------------}
function TXPMatch.getAttribute(i: integer): TAttr;
begin
    if ((i >= 0) and (i < _AttrList.Count)) then
        Result := TAttr(_AttrList.Node(i))
    else
        Result := nil;
end;

{---------------------------------------}
function TXPMatch.GetAttrCount: integer;
begin
    Result := _AttrList.Count;
end;

{---------------------------------------}
procedure TXPMatch.Parse(xps: Widestring);
var
    l, i, s, s2: integer;
    state: integer;
    xp, q, name, val, c, cur: Widestring;
begin
    // this should be a single "block"
    // parse the /foo[@a="b"][@c="d"] stuff
    // could be: /foo@a also to just get the attribute
    i := 2;
    xp := Trim(xps);
    l := Length(xp);
    state := 0;
    cur := '';
    while (i <= l) do begin
        c := xp[i];
        if (c = '[') then begin
            // this is a where clause
            if (state = 0) then
                tag_name := cur;
            inc(i); // should be pointing to '@'
            inc(i); // should be pointing to first letter of attr
            s := i;
            while ((i <= l) and (xp[i] <> '=')) do
                inc(i);
            name := Copy(xp, s, (i-s));

            inc(i); // point to "
            s2 := i;
            q := xp[i];
            inc(i); // point to first letter
            while ((i <= l) and (xp[i] <> q)) do
                inc(i);
            val := TrimQuotes(Copy(xp, s2, (i-s2) + 1));
            PutAttribute(name, val);
            state := 1;
            inc(i);
            end
        else if (c = '@') then begin
            // specific attribute
            if (state = 0) then
                tag_name := cur;
            inc(i); // should be pointing at the attribute name now
            s := i;
            while ((i <= l) and (xp[i] <> '@')) do
                inc(i);
            name := Copy(xp, s, (i-s));
            val := '';
            PutAttribute(name, val);
            end
        else if (state = 0) then
            cur := cur + c;
        inc(i);
        end;

    if (state = 0) then
        tag_name := cur;
end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TXPLite.Create;
begin
    inherited;

    attr := '';
    value := '';

    Matches := TWideStringList.Create;
end;

{---------------------------------------}
destructor TXPLite.Destroy;
begin
    ClearStringListObjects(Matches);
    Matches.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TXPLite.Parse(xps: Widestring);
var
    s, l, i, f: integer;
    c, cur: Widestring;
    m: TXPMatch;
begin
    // parse the full /foo/bar[@xmlns="jabber:iq:roster"] string
    {
    Could also be:
    /foo/bar/cdata
    /foo/bar@xmlns
    }
    matches.Clear;
    s := 1;
    i := 2;
    l := Length(xps);
    cur := '';
    c := '';
    m := nil;
    while (i <= l) do begin
        c := xps[i];

        if ((c = '"') or (c = Chr(39))) then begin
            // we are in a quote sequence, find the matching quote
            f := i + 1;
            while ((f <= l) and (xps[f] <> c)) do
                inc(f);
            if (f <= l) then
                i := f;
            end;

        if ((c = '/') or (i = l)) then begin
            // we've reached a seperator
            if c = '/' then
                cur := Copy(xps, s, (i-s))
            else
                cur := Copy(xps, s, (i - s) + 1);
            s := i;

            if ((Lowercase(cur) = 'cdata') and (m <> nil)) then
                m.get_cdata := true
            else begin
                m := TXPMatch.Create;
                m.parse(cur);
                Matches.AddObject(m.tag_name, m)
                end;
            end;
        inc(i);
        end;
end;

{---------------------------------------}
function TXPLite.Query(Tag: TXMLTag): Widestring;
begin
    //
    result := '';
end;

{---------------------------------------}
function TXPLite.checkTags(Tag: TXMLTag; match_idx: integer): TXMLTagList;
var
    cm: TXPMatch;
    ca: TAttr;
    i, a: integer;
    r, tl: TXMLTagList;
    t: TXMLTag;
    wild_card: boolean;
    tmps: Widestring;
    add: boolean;
begin
    // find the tags that matches the specific TXPMatch object
    r := TXMLTagList.Create();
    cm := TXPMatch(Matches.Objects[match_idx]);

    // check tag names
    if (match_idx = 0) then begin
        tl := TXMLTagList.Create();
        tl.Add(Tag);
        end
    else begin
        // check to see if we have a wildcard tag name..
        if (cm.tag_name = '*') then
            tl := Tag.ChildTags()
        else
            tl := Tag.QueryTags(cm.tag_name);
        end;

    // Check all the tags in the taglist
    for i := 0 to tl.Count - 1 do begin
        t := tl.Tags[i];
        add := false;

        // Check ea. tag for the appropriate tag name
        if ((cm.tag_name = '*') or (t.Name = cm.tag_name)) then begin
            add := true;

            // Check ea. tag to make sure it has the correct attributes
            for a := 0 to cm.AttrCount - 1 do begin
                ca := cm.getAttribute(a);
                wild_card := (Copy(ca.Value, length(ca.Value), 1) = '*');
                if wild_card then begin
                    tmps := ca.Value;
                    Delete(tmps, length(tmps), 1);
                    if (Pos(Lowercase(tmps), Lowercase(t.getAttribute(ca.Name))) <= 0) then
                        add := false;
                    end
                else if (ca.Value <> '') then begin
                    if (Lowercase(t.getAttribute(ca.name)) <> Lowercase(ca.Value)) then
                        add := false;
                    end;
                end;
            end;

        // If the add flag is still true, add the tag to the result set
        if (add) then
            r.Add(t);
        end;
    tl.Free();
    
    Result := r;
end;

{---------------------------------------}
function TXPLite.GetTags(tag: TXMLTag): TXMLTagList;
var
    t: TXMLTag;
    c, i, m: integer;
    r, ntags, ctags, mtags: TXMLTagList;
begin
    {
    Iteratively search the xplite looking for tags
    that match. We want to return a list of all
    the matching tags
    }
    m := 0;
    t := tag;
    r := TXMLTagList.Create();
    ctags := TXMLTagList.Create();
    ntags := TXMLTagList.Create();

    // compile the list of tags that match the entire xplite
    ctags.Add(t);
    repeat
        for c := 0 to ctags.Count - 1 do begin
            mtags := checkTags(ctags[c], m);
            if (m = Matches.Count - 1) then begin
                ntags.Clear;
                for i := 0 to mtags.Count - 1 do
                    r.add(mtags.tags[i]);
                end
            else begin
                for i := 0 to mtags.Count - 1 do
                    ntags.Add(mtags[i]);
                end;
            mtags.Free;
            end;
        inc(m);
        ctags.Assign(ntags);
        ntags.Clear;
    until (m >= Matches.Count) or (ntags.Count < 0);
    ntags.Free;
    ctags.Free;

    Result := r;
end;

{---------------------------------------}
function TXPLite.doCompare(tag: TXMLTag; start: integer): boolean;
var
    t, next: integer;
    mtags: TXMLTagList;
begin
    // check this tag and subsequent ones against the start match
    mtags := checkTags(tag, start);

    if (mtags.Count > 0) then begin
        // we have matching tags
        next := start + 1;
        if (next = Matches.Count) then begin
            // we have successfully matched everything
            Result := true;
            end
        else begin
            // Check the next level
            Result := true;
            for t := 0 to mtags.Count - 1 do
                Result := Result and (doCompare(mtags.Tags[t], next));
            end;
        end
    else
        Result := false;

    mtags.Free;
end;

{---------------------------------------}
function TXPLite.Compare(Tag: TXMLTag): boolean;
begin
    // compare a tag against this XPLite object
    if (Matches.Count <= 0) then begin
        Result := true;
        exit;
        end;

    // check the first level, and kick off doCompares
    Result := doCompare(Tag, 0);
end;

{---------------------------------------}
function TXPLite.GetString: Widestring;
var
    m: TXPMatch;
    ca: TAttr;
    a, i: integer;
begin
    // get the xplite string representation
    Result := '';

    for i := 0 to Matches.Count - 1 do begin
        m := TXPMatch(Matches.Objects[i]);
        Result := Result + '/' + m.tag_name;

        for a := 0 to m.AttrCount - 1 do begin
            ca := m.getAttribute(a);
            if (ca.Value = '') then
                Result := Result + '@' + ca.Name
            else
                Result := Result + '[@' + ca.Name + '="' + ca.Value + '"]';
            end;
        end;
end;

end.
