unit uWinApi;


// http://bbs.pediy.com/thread-217610.htm
// ΢��(WeChat)���Զ˶࿪����+Դ��

{  ��лԭ���ṩ�Ĵ���� exe
   ������2013 qq 26562729
   2017-07-04
   // ��������ѧϰ win api ��һ������ʾ��
   // ϣ�����������ջ�
}
interface

uses
  windows, TLHelp32, Generics.collections,System.SysUtils;

type
  PSystemHandle = ^TSystemHandle; // �˽ṹ��δ���������˺ܾò�Ū��ȷ��

  TSystemHandle = packed record // ��16�ֽ�. ����һ��Ҫ׼ȷ�����򣬺���û���档
    dwProcessID: THandle;
    bObjectType: Byte;
    bflags: Byte;
    wValue: Word;
    GrantedAcess: Int64;
  end;

  PSystemHandleList = ^TSystemHandleList;

  TSystemHandleList = record
    dwHandleCount: Cardinal; // ��ȡ���Ľ��ǰ4���ֽڣ���ʾ����
    // ����ľ�ÿ 16 ���ֽ�һ�飬��ʾһ�� TSystemHandle
    Handles: array of TSystemHandle; // �������������������С�
    // Handles:TSystemHandle; ֻ�ǲ��������
  end;

  PProcessRec = ^TProcessRec;

  TProcessRec = record
    ProcessName: string;
    ProcessID: THandle;
  end;

  TProcessRecList = class(TList<PProcessRec>)
  public
    procedure FreeAllItem;
  end;

  // win �����£������õ����ߴ��� buff ���ȣ�Ȼ������������Ƿ����
  // ����������ͷ���һ�����󣬲����� ASize ��ָ����Ҫ�ĳ���
  // �Ա���������·��� buff �ٴε���
  // ASysInfoCls �ǲ�ѯʲô��� MS û��ȫ������. $10 Ϊ SystemHanle.
  // ASysInfo ���Ϊ Buff �����ˡ�
function ZwQuerySystemInformation(ASysInfoCls: Integer; ASysInfo: Pointer; ABufLen: Cardinal; var ASize: Cardinal): Cardinal; stdcall; external 'ntdll.dll';

function NtQueryObject(Ahandle: THandle; AQuertyIndex: Integer; ABuff: Pointer; ABuffSize: Cardinal; var ASize: Cardinal): Cardinal; stdcall; external 'ntdll.dll';

// ��ȡ��ǰ�Ľ���
function GetAllProcess: TProcessRecList;

function FileVersion(const FileName: string): string;

implementation

{ TProcessRecList }

procedure TProcessRecList.FreeAllItem;
var
  p: PProcessRec;
begin
  for p in self do
    Dispose(p);
end;

function GetAllProcess: TProcessRecList;
var
  Entry32: TProcessEntry32W;
  SnapshotHandle: THandle;
  Found: boolean;
  sExeFileName: string;
  p: PProcessRec;
begin
  Result := TProcessRecList.Create;
  SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  Entry32.dwSize := sizeof(Entry32);
  Found := Process32First(SnapshotHandle, Entry32);
  while Found do
  begin
    new(p);
    Result.Add(p);
    sExeFileName := Entry32.szExeFile;
    p.ProcessName := sExeFileName;
    p.ProcessID := Entry32.th32ProcessID;
    Found := Process32Next(SnapshotHandle, Entry32);
  end;
  CloseHandle(SnapshotHandle);
end;

function FileVersion(const FileName: string): string;
var
  VerInfoSize: Cardinal;
  VerValueSize: Cardinal;
  Dummy: Cardinal;
  PVerInfo: Pointer;
  PVerValue: PVSFixedFileInfo;
  iLastError: DWord;
begin
  Result := '';
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  if VerInfoSize > 0 then
  begin
    GetMem(PVerInfo, VerInfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, PVerInfo) then
      begin
        if VerQueryValue(PVerInfo, '\', Pointer(PVerValue), VerValueSize) then
          with PVerValue^ do
            Result := Format('%d.%d.%d.%d', [HiWord(dwFileVersionMS), //Major
              LoWord(dwFileVersionMS), //Minor
              HiWord(dwFileVersionLS), //Release
              LoWord(dwFileVersionLS)]); //Build
      end
      else
      begin
        iLastError := GetLastError;
        Result := Format('GetFileVersionInfo failed: (%d) %s', [iLastError, SysErrorMessage(iLastError)]);
      end;
    finally
      FreeMem(PVerInfo, VerInfoSize);
    end;
  end
  else
  begin
    iLastError := GetLastError;
    Result := Format('GetFileVersionInfo failed: (%d) %s', [iLastError, SysErrorMessage(iLastError)]);
  end;
end;

end.

