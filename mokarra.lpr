{*****************************************************************************}
{                   _                                                         }
{       /\/\   ___ | | ____ _ _ __ _ __ __ _                                  }
{      /    \ / _ \| |/ / _` | '__| '__/ _` |                                 }
{     / /\/\ \ (_) |   < (_| | |  | | | (_| |                                 }
{     \/    \/\___/|_|\_\__,_|_|  |_|  \__,_|                                 }
{                                                                             }
{ Mokarra                                                                     }
{   (C)opyright 2011-2015 - LeafScale Systems, Inc.                           }
{                                                                             }
{ This software is protected under the LeafScale Software License             }
{                                                                             }
{*****************************************************************************}
{ /mokarra.lpr                                                                }
{ Main Program Executable / Main Lazarus Project                              }
{*****************************************************************************}

program mokarra;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, Crt, UriParser,
  ConfigFile, ConfigMenu, SystemInfo,
  ReefIndex, ReefRepo, PkgSrc, Version;

type
  { TMokarra }

  TMokarra = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteBanner; virtual;
    procedure WriteHelp; virtual;
  end;

var
  QuietOutput   : BOOLEAN = False;
  VerboseOutput : BOOLEAN = False;
{ TMokarra }

procedure TMokarra.DoRun;
var
  ErrorMsg : String;
  //Cfg : MasterConfig;
  ParseValue : String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('hQvVcsit','help quiet version verbose config sysinfo index test');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('Q','quiet') then begin
    QuietOutput := True;
  end;

  WriteBanner;

  if (self.ParamCount = 0 ) then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  if HasOption('s','sysinfo') then begin
    SystemDisplayInfo();
    Terminate;
    Exit;
  end;

  if HasOption('v','version') then begin
    writeln('Mokarra Version = ', MOKARRA_VERSION);
    writeln('  Build Release = ', MOKARRA_RELEASE);
    Terminate;
    Exit;
  end;

  if HasOption('p','pkginfo') then begin
    //ParseValue := GetOptionValue('p','parse');
    //ParsePkgSrcFile(ParseValue+ '.pkgsrc');
    Terminate;
    Exit;
  end;

  if HasOption('i','index') then begin
    BuildReefIndex;
    Terminate;
    Exit;
  end;

  if HasOption('c','config') then begin
    ConfigMenuMain();
    Terminate;
    Exit;
  end;

  if HasOption('V','verbose') then begin
    VerboseOutput := True;
    if (VerboseOutput = True) then
      writeln('Verbose Mode = ON');
  end;

  { add your program here }

  // stop program loop
  Terminate;
end;

constructor TMokarra.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMokarra.Destroy;
begin
  inherited Destroy;
end;

{* Display the program banner *}
procedure TMokarra.WriteBanner;
begin
  if (QuietOutput = False) then
  begin
    TextColor(LightCyan);
    write('M');
    TextColor(Cyan);
    write('okarra ');
    TextColor(LightCyan);
    write('v');
    TextColor(Cyan);
    write(MOKARRA_VERSION);
    TextColor(DarkGray);
    write(' : (');
    TextColor(LightGray);
    write('C');
    TextColor(DarkGray);
    write(')opyright');
    TextColor(DarkGray);
    write(' 2015, ');
    TextColor(LightBlue);
    write('LeafScale, Inc. ');
    TextColor(DarkGray);
    write('[');
    TextColor(Blue);
    write('http://www.leafscale.com');
    TextColor(DarkGray);
    write(']');
    TextColor(LightGray);
    writeln();
  end;
end;

{* Display the program help *}
procedure TMokarra.WriteHelp;
begin
  TextColor(LightGray);
  write('Usage: ');
  TextColor(White);
  write(ExeName);
  TextColor(Yellow);
  write(' [option]');
  TextColor(LightGray);
  writeln();

  writeln();
  TextColor(LightBlue); write(' -c ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --config');
  TextColor(DarkGray);  write('  :  ');
  TextColor(LightGray); write('configure');

  writeln();
  TextColor(LightBlue); write(' -s ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --sysinfo');
  TextColor(DarkGray);  write(' :  ');
  TextColor(LightGray); write('display sysinfo');

  writeln();
  TextColor(LightBlue); write(' -Q ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --quiet');
  TextColor(DarkGray);  write('   :  ');
  TextColor(LightGray); write('quiet mode');

  writeln();
  TextColor(LightBlue); write(' -V ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --verbose');
  TextColor(DarkGray);  write(' :  ');
  TextColor(LightGray); write('verbose mode');

(*
  writeln();
  TextColor(LightBlue); write(' -p ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --parse=');
  TextColor(DarkGray);  write('    :  ');
  TextColor(LightGray); write('parse pkgsrc [filename]');

  writeln();
  TextColor(LightBlue); write(' -r ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --rebuild');
  TextColor(DarkGray);  write('    :  ');
  TextColor(LightGray); write('rebuild reef index');
*)

  writeln();
  TextColor(LightBlue); write(' -i ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --index');
  TextColor(DarkGray);  write('   :  ');
  TextColor(LightGray); write('build reef index');

  writeln();
  TextColor(LightBlue); write(' -v ');
  TextColor(DarkGray);  write('|');
  TextColor(LightBlue); write(' --version');
  TextColor(DarkGray);  write(' :  ');
  TextColor(LightGray); write('display version');
  writeln();
 end;


var
  Application: TMokarra;

{$IFDEF WINDOWS}{$R mokarra.rc}{$ENDIF}

begin
  Application:=TMokarra.Create(nil);
  Application.Title:='Mokarra';
  Application.Run;
  Application.Free;
end.

