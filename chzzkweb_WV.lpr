program chzzkweb_WV;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Windows,
  ChzzkWeb_Main, uChecksumList, uniqueinstance_package, rxnew
  { you can add units after this };

{$R *.res}

{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

begin
  RequireDerivedFormResource:=True;
  IsMultiThread:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFormChzzkWeb, FormChzzkWeb);
  Application.Run;
end.

