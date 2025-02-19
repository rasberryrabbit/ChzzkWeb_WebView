unit csscolortable_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ValEdit, StdCtrls;

type

  { TFormCssTable }

  TFormCssTable = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBoxSaveTable: TCheckBox;
    CSSTable: TValueListEditor;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  FormCssTable: TFormCssTable;

implementation

uses
  RegExpr, StrUtils;

{$R *.lfm}

{ TFormCssTable }

procedure TFormCssTable.Button1Click(Sender: TObject);
const
  spat = '(html|[\.#][a-zA-Z_])([^{]+)?\{(\s+)?--([^\}]+)\}';
var
  st: TStringList;
  i, j, k, v, w, z: Integer;
  s, ck, rs: string;
  stable: TStringStream;
  sexpr: TRegExpr;

  procedure GetCSSItem;
  begin
    i:=1;
    j:=Pos(';',rs);
    while j>0 do begin
      st.Add(Copy(rs,i,j-i+1));
      i:=j+1;
      j:=PosEx(';',rs,i);
    end;
    if j=0 then
      j:=Length(rs);
    if i<j then
      st.Add(Copy(rs,i,j-i+1));
  end;

begin
  st:=TStringList.Create;
  try
    Button1.Enabled:=False;
    st.Clear;
    // extract Var()
    stable:= TStringStream.Create('');
    try
      stable.LoadFromFile('doc\main.56f98435.css');
      s:=stable.DataString;
      stable.Clear;
      sexpr:=TRegExpr.Create(spat);
      try
        if sexpr.Exec(s) then begin
          rs:=sexpr.Match[0];
          GetCSSItem;
        end;

        while sexpr.ExecNext() do begin
          rs:=sexpr.Match[0];
          GetCSSItem;
        end;
      finally
        sexpr.Free;
      end;
    finally
      stable.Free;
    end;

    if CheckBoxSaveTable.Checked then
      st.SaveToFile('doc\dark_theme_table.txt');
    CSSTable.Clear;
    for z:=0 to 1 do
      for i:=0 to st.Count-1 do begin
        s:=st.Strings[i];
        j:=Pos('{',s);
        if j>0 then
          s:=Copy(s,j+1);
        j:=Pos('}',s);
        if j>0 then
          s:=Copy(s,1,j-1);
        j:=Pos(':',s);
        if j=0 then
          j:=1;
        k:=Pos(';',s);
        if k=0 then
          k:=Length(s)
          else
            Dec(k);
        v:=Pos('var(',s);
        w:=Pos(')',s);
        if (v>0) and (w>v) then begin
          ck:=Trim(Copy(s,v+4,w-v-4));
          rs:=CSSTable.Values[ck];
        end
        else
          rs:=Trim(Copy(s,j+1,k-j));
        ck:=Trim(Copy(s,1,j-1));
        if CSSTable.FindRow(ck,w) then begin
          if rs<>'' then
            CSSTable.Values[ck]:=rs;
        end else
            CSSTable.InsertRow(ck,rs,True);
      end;
  finally
    st.Free;
    Button1.Enabled:=True;
  end;
end;

function CodeWalk(const s:string; ipos: Integer):Integer;
var
  i, l, id: Integer;
  ch: char;
begin
  Result:=ipos;
  l:=Length(s);
  id:=1;
  while ipos<=l do begin
    ch:=s[ipos];
    if ch=')' then begin
      if id>0 then begin
          Dec(id);
          if id=0 then begin
              Result:=ipos;
              break;
          end;
      end else
        break;
    end else
    if ch='(' then begin
        Inc(id);
    end;
    Inc(ipos);
  end;
end;

procedure TFormCssTable.Button2Click(Sender: TObject);
const
  rport = 'var\(([^\),]+)(\)|,)';
var
  fs: TStringStream;
  RegVarColor: TRegExpr;
  res, ncolor: string;
  i, j, k, m: Integer;
  tick: int64;
begin
  res:='';
  i:=1;
  fs := TStringStream.Create('');
  try
    Button2.Enabled:=False;
    fs.LoadFromFile('doc\main.56f98435.css');
    RegVarColor:=TRegExpr.Create(rport);
    try
      tick:=GetTickCount64;
      // first item
      if RegVarColor.Exec(fs.DataString) then
      begin
        j:=RegVarColor.MatchPos[0];
        ncolor:=CSSTable.Values[RegVarColor.Match[1]];
        if ncolor<>'' then begin
          res:=res+Copy(fs.DataString,i,j-i)+ncolor;
          m:=j+RegVarColor.MatchLen[0]-1;
          k:=CodeWalk(fs.DataString,m);
          if k>m then
            res:=res+Copy(fs.DataString,m,k-m);
          j:=j+k-m;
        end else
          res:=res+Copy(fs.DataString,i,j-i)+RegVarColor.Match[0];
        i:=j+RegVarColor.MatchLen[0];
      end;

      // second item
      while RegVarColor.ExecNext do
      begin
        j:=RegVarColor.MatchPos[0];
        ncolor:=CSSTable.Values[RegVarColor.Match[1]];
        if ncolor<>'' then begin
          res:=res+Copy(fs.DataString,i,j-i)+ncolor;
          m:=j+RegVarColor.MatchLen[0]-1;
          k:=CodeWalk(fs.DataString,m);
          if k>m then
            res:=res+Copy(fs.DataString,m,k-m);
          j:=j+k-m;
        end else
          res:=res+Copy(fs.DataString,i,j-i)+RegVarColor.Match[0];
        i:=j+RegVarColor.MatchLen[0];
        if GetTickCount64-tick>2000 then begin
          tick:=GetTickCount64;
          Application.ProcessMessages;
        end;
      end;
      res:=res+Copy(fs.DataString,i);
      // save to file
      fs.Clear;
      fs.WriteString(res);
      if Memo1.Text<>'' then
        fs.WriteString(Memo1.Text);
      fs.SaveToFile('doc\main.56f98435-dark.css');
    finally
      RegVarColor.Free;
    end;
  finally
    fs.Free;
    Button2.Enabled:=True;
  end;
end;

end.

