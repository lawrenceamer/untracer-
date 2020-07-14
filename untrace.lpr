
{

 untrace is small tool to run binaries with any desired extension

}

program untrace;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,process,WINDOWS
  { you can add units after this };

const
  BUF_SIZE = 2024;
type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
    procedure runit;virtual;
  public
  end;

{ TMyApplication }

 function SystemFolder: string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result, Windows.GetSystemDirectory(PChar(Result), Windows.MAX_PATH)
  );
end;

 function untracer(cmd:string;arg:string):string;
var
    process : Tprocess;
    output: string;
    list : Tstringlist;
    OutputStream : TStream;
    BytesRead    : longint;
    Buffer       : array[1..BUF_SIZE] of byte;

 begin
   list := Tstringlist.Create;
   process := Tprocess.Create(nil);
   OutputStream := TMemoryStream.Create;    // we are going to store outputs as memory stream .
   process.Executable:=systemfolder+'\cmd.exe';
   process.CommandLine:=cmd; // we can add value of arg into params to control plugin output
   try
   process.Options:= [poUsePipes];
   process.Execute;
    repeat
    // Get the new data from the process to a maximum of the buffer size that was allocated.
    // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
      BytesRead := Process.Output.Read(Buffer, BUF_SIZE);
      OutputStream.Write(Buffer, BytesRead)
    until BytesRead = 0;    //stop if no more data is being recieved

  outputstream.Position:=0;
  list.LoadFromStream(outputstream);
  writeln(list.Text);

   finally
   process.Free;
   list.Free;
   end;
end;
procedure TMyApplication.runit;
var
i:integer;
binary:string;
begin
  for i := 0 to paramcount do begin
  if (paramstr(i)='-f') then begin
    binary := paramstr(i+1);
  end;
end;
  untracer(binary,'');
end;

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
    ErrorMsg:=CheckOptions('m f', 'mode file');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;
    if hasoption('m','mode') then begin
      runit;
    end;
  { add your program here }

  // stop program loop
  Terminate;
end;

var
  Application: TMyApplication;
begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='untrace';
  Application.Run;
  Application.Free;
end.

