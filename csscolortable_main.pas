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
    CSSTable: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  FormCssTable: TFormCssTable;

implementation

uses
  RegExpr;

{$R *.lfm}

{ TFormCssTable }

procedure TFormCssTable.Button1Click(Sender: TObject);
var
  st: TStringList;
  i, j, k, v, w: Integer;
  s, ck, rs: string;
begin
  st:=TStringList.Create;
  try
    st.LoadFromFile('doc\dark_theme_table.txt');
    CSSTable.Clear;
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
        ck:=Copy(s,v+4,w-v-4);
        rs:=CSSTable.Values[ck];
      end
      else
        rs:=Copy(s,j+1,k-j);
      ck:=Copy(s,1,j-1);
      if CSSTable.FindRow(ck,w) then
          CSSTable.Values[ck]:=rs
        else
          CSSTable.InsertRow(ck,rs,True);
    end;
  finally
    st.Free;
  end;
end;

procedure TFormCssTable.Button2Click(Sender: TObject);
const
  rport = '(?-s)(var\()([^\)]+)(\))';
var
  fs: TStringStream;
  regport: TRegExpr;
  res: string;
  i, j: Integer;
begin
  res:='';
  i:=1;
  fs := TStringStream.Create('');
  try
    fs.LoadFromFile('doc\main.56f98435.css');
    regport:=TRegExpr.Create(rport);
    try
      // first item
      if regport.Exec(fs.DataString) then
      begin
        j:=regport.MatchPos[1];
        if CSSTable.Values[regport.Match[2]]<>'' then
          res:=res+Copy(fs.DataString,i,j-i)+CSSTable.Values[regport.Match[2]]
          else
            res:=res+Copy(fs.DataString,i,j-i)+regport.Match[0];
        i:=regport.MatchPos[3]+1;
      end;

      // second item
      while regport.ExecNext do
      begin
        j:=regport.MatchPos[1];
        if CSSTable.Values[regport.Match[2]]<>'' then
          res:=res+Copy(fs.DataString,i,j-i)+CSSTable.Values[regport.Match[2]]
          else
            res:=res+Copy(fs.DataString,i,j-i)+regport.Match[0];
        i:=regport.MatchPos[3]+1;
      end;
      res:=res+Copy(fs.DataString,i);
      // save to file
      fs.Clear;
      fs.WriteString(res);
      fs.SaveToFile('doc\main.56f98435-dark.css');
    finally
      regport.Free;
    end;
  finally
    fs.Free;
  end;
end;

end.

