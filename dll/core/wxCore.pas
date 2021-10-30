unit wxCore;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, tlhelp32,
  Jpeg, u_debug, PsAPI, Vcl.StdCtrls, Vcl.ExtCtrls, IdBaseComponent, IdComponent,
  qrenc, IdTCPConnection, IdTCPClient, IdHTTP;

type
  GeneralStruct = record
    pstr: pchar;
    iLen: integer;
    iMaxLen: integer;
    full1: integer;
    full2: integer;
  end;

var
  SendMsgCallBuff1: array[0..$81C - 1] of char;   //必须外面
  SendMsgCallBuff2: array[0..$81C - 1] of char;
  g_baseaddr: Nativeuint;

const
  nickname_offset = $1ad1bac;  //昵称  wx 3.2.1.154


//  发送消息

procedure SendMsg(wxid, txtData: string);

//  跳转到二维码
procedure GotoQr();

//免打扰
procedure TmpShield(f: Boolean);

//取得二维码字符串
function QrStr: string;

//修改昵称
procedure ChangeNickname(NewNickname: string);

function GetNickname: string;

//省市
function GetRegion: string;

//签名
function GetSign: string;

function GetPhone: string;

function GetWxid: string;
//得到头像url

function GetHeadUrl: string;

function CheckLogin(): Boolean;

function GetNicknameByWxid(): string;

//防撤回

procedure AntiRevoke(f: Boolean);

//同意添加
procedure AgreeUserRequest(auto_vv1, auto_vv2: string);

//自动添加好友 数据结构
type
//V1
  v1Info = packed record
    fill: Integer;
    v1: pchar;
    v1Len: Integer;
    maxV1Len: Integer;
    fill2: array[0..$41c - 1] of ansichar;
    v2: PChar; // DWORD;
  end;



//V2     const	 fill3 = $25;
  v2Info = packed record
    fill: array[0..$24C - 1] of AnsiChar;
    fill3: DWORD;
    fill4: array[0..$40 - 1] of AnsiChar;
    v2: pchar;
    v2Len: integer;
    maxV2Len: Integer;
    fill2: array[0..$8 - 1] of AnsiChar;
  end;

var
  buffA: array[0..$14 - 1] of ansichar;
  buff2B: array[0..$48 - 1] of ansichar;

//  auto_vv1:string;
//  auto_vv2:string;
  //----------}

var
  tmpbuff: array[0..$3D8 - 1] of char;    //临时
  userData: DWORD = 0;		//用户数据的地址
  tmp_GetNicknameByWxid: string;

var
  userInfoV1: v1Info;
  userInfoV2: v2Info;

var
  callAdd1, callAdd2, callAdd3, callAdd4, params: dword;

implementation

procedure AntiRevoke(f: Boolean);
var
  fix: byte;
  oldByte: Byte;
var
  OldProtect: DWORD;
begin
  fix := $eb;
  oldByte := $74;
  var Address := Pointer(g_baseaddr + $3ded99);
  VirtualProtect(Address, 1, PAGE_EXECUTE_READWRITE, OldProtect);
  if f then
    CopyMemory(Address, @fix, 1)  //memcpy
  else
    CopyMemory(Address, @oldByte, 1);  //memcpy
    	//恢复属性
  VirtualProtect(Address, 5, OldProtect, OldProtect);
end;

         //同意好友请求
procedure AgreeUserRequest(auto_vv1, auto_vv2: string);
begin

  const WxAgreeUserRequestCall1 = $1F036;		//同意好友请求 1
  const WxAgreeUserRequestCall2 = $5D60;		//同意好友请求 1
  const WxAgreeUserRequestCall3 = $10FFA0;		//同意好友请求 1
  const WxAgreeUserRequestCall4 = $1D7180;		//同意好友请求 1
  const WxAgreeUserRequestParam = $1AB2E98;	//同意好友请求 1

  callAdd1 := g_baseaddr + WxAgreeUserRequestCall1;
  callAdd2 := g_baseaddr + WxAgreeUserRequestCall2;
  callAdd3 := g_baseaddr + WxAgreeUserRequestCall3;
  callAdd4 := g_baseaddr + WxAgreeUserRequestCall4;
  params := g_baseaddr + WxAgreeUserRequestParam;

  ZeroMemory(@userInfoV1, SizeOf(v1Info));
  ZeroMemory(@userInfoV2, SizeOf(v2Info));
  ZeroMemory(@buffA[0], $14 - 1);
  ZeroMemory(@buff2B[0], $48 - 1);

  userInfoV1.fill := 0;

  userInfoV1.v2 := (@userInfoV2);
  userInfoV1.v1 := PChar(auto_vv1); // Pointer((@v1)^);
//  debug.Show('=================' + userInfoV1.v1);

  userInfoV1.v1Len := auto_vv1.Length;
  userInfoV1.maxV1Len := auto_vv1.Length * 2;

  userInfoV2.fill3 := $25;
  userInfoV2.v2 := PChar(auto_vv2); // Pointer((@v2)^);
//    debug.Show('=================' + userInfoV2.v2);
  userInfoV2.v2Len := auto_vv2.Length;
  userInfoV2.maxV2Len := auto_vv2.Length * 2;

  var asmUser: PansiChar;
  asmUser := @userInfoV1;

  var asmBuff: PAnsiChar;
  asmBuff := @buff2B;

//    debug.Show('=================' + asmUser);
  var vvvxp: pdword;
  vvvxp := pdword(params);
  asm
        pushad;
        mov     ecx, asmUser;
        push    $11;
        sub     esp, $14;
        push    esp;
        call    callAdd1;
        mov     ecx, asmUser;
        lea     eax, buffa;
        push    eax;
        call    callAdd2;
        mov     esi, eax;
        sub     esp, $8;
        mov     ecx, vvvxp;
        call    callAdd3;
        mov     ecx, asmBuff;
        mov     edx, ecx;
        push    edx;
        push    eax;
        push    esi;
        call    callAdd4;
     //   add esp,4
//                add esp,4
//                        add esp,4
        popad;
  end
end;

function GetNicknameByWxid(): string;
var
  vGeneralStruct: GeneralStruct;
  userwxid: string;
begin
  userwxid := tmp_GetNicknameByWxid;
  var dwCall1 := g_baseaddr + $58da50;
  var dwCall2 := g_baseaddr + $63930;
  var dwCall3 := g_baseaddr + $3245e0;

  vGeneralStruct.pstr := Pointer((@userwxid)^); //   PChar(userwxid);
  vGeneralStruct.iLen := userwxid.Length;
  vGeneralStruct.iMaxLen := userwxid.Length * 2;
  vGeneralStruct.full1 := 0;
  vGeneralStruct.full2 := 0;
  var asmWxid: PAnsiChar;
  asmWxid := @vGeneralStruct;
  ZeroMemory(@tmpbuff[0], $3D8 - 1);


//  debug.Show('*********************************');
//	GeneralStruct pWxid(userwxid);
//	char* asmWxid = (char*)& pWxid.pstr;
//	char buff[0x3D8] = { 0 };
//	DWORD userData = 0;		//用户数据的地址
  asm

        pushad;
        lea     edi, tmpbuff;
        push    edi;
        sub     esp, $14;
        mov     eax, asmWxid;
        mov     ecx, esp;
        push    eax;
        call    dwCall1;
        call    dwCall2;
        call    dwCall3;
        mov     userData, edi;
//        add esp,8     ;
//        add esp,$14
        popad;
  end;
  var tempnickname: string;
  var wxNickAdd := userData + $64;	//昵称
  tempnickname := PChar(wxNickAdd);
//	swprintf_s(tempnickname, L"%s", (wchar_t*)(*((LPVOID*)wxNickAdd)));

  result := tempnickname;
end;

function GetWxid: string;
begin
  const wxid_offset = $1ad1fb0;       //微信id  wx 3.2.1.154
  result := PansiChar(g_baseaddr + wxid_offset);
end;

function GetPhone: string;
begin
  const phone_offset = $1ad1b10; //手机号  //wx 3.2.1.154
  result := PansiChar(g_baseaddr + phone_offset);
end;

function GetHeadUrl: string;
begin
  const head_offset = $1ad1e74;     //头像  wx 3.2.1.154
  var p1: Nativeuint;
  p1 := g_baseaddr + head_offset;    //二级指针
  result := PansiChar(Pointer((@p1)^)^);
end;

function GetNickname: string;
var
  NewDest: PChar;
begin
  GetMem(NewDest, 100);

  var mys := PansiChar(g_baseaddr + nickname_offset);
  Utf8toUnicode(NewDest, mys, 100);

  result := WideCharToString(NewDest);
  freemem(NewDest);
end;

function GetRegion: string;
var
  NewDest: PChar;
begin
  GetMem(NewDest, 100);
  const region_offset = $1ad1c98;    //wx 3.2.1.154
  var region_ := PansiChar(g_baseaddr + region_offset);
  Utf8toUnicode(NewDest, region_, 100);
  result := WideCharToString(NewDest);
  freemem(NewDest);
end;

function GetSign: string;
//取得签名
var
  NewDest: PChar;
begin
  const sign_offset = $1ad1cc8;   //wx 3.2.1.154  个性签名
  GetMem(NewDest, 100);
  var qm_ := PansiChar(g_baseaddr + sign_offset);
  Utf8toUnicode(NewDest, qm_, 100);
  result := WideCharToString(NewDest);
  freemem(NewDest);
end;

procedure ChangeNickname(NewNickname: string);
var
  lpNumberOfBytesWritten: SIZE_T;
var
  Dest: Pansichar;
  Unic: Pchar;
  str: ansistring;
  NewDest: PChar;
begin

  const nickname_len_offset = $1ad1bbc;    //昵称长度   wx 3.2.1.154
  GetMem(Unic, 100);

  GetMem(Dest, 100);
  UnicodeToUtf8(Dest, StringToWideChar(NewNickname, Unic, 100), 100);
  if Length(Dest) <= 15 then
  begin
    WriteProcessMemory(GetCurrentProcess, Pointer(g_baseaddr + nickname_offset), Dest, Length(Dest), lpNumberOfBytesWritten);

    var value: byte;
    value := Length(Dest);
                                 //写入名字长度
    writeprocessmemory(GetCurrentProcess, Pointer(g_baseaddr + nickname_len_offset), @value, 1, lpNumberOfBytesWritten);
  end;

end;

procedure SimulateAClickQr();
//模拟点击  二维码
begin
  var a: tpoint;
  GetCursorPos(a);  //取得鼠标坐标,并存放进a中
  var h := FindWindow('WeChatLoginWndForPC', '微信');
  SetWindowPos(h, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE); //不置顶
  var point: TPoint;
  point.x := 142;
  point.y := 347;
  Winapi.Windows.ClientToScreen(h, point);
  setcursorpos(point.x, point.y);
  mouse_event(MOUSEEVENTF_LEFTDOWN, point.x, point.y, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, point.x, point.y, 0, 0);

  setcursorpos(a.x, a.y);
end;

function QrStr: string;
begin    //得到二维码
result:='abc';

end;

procedure TmpShield(f: Boolean);
 //临时免打扰
begin
  var lpNumberOfBytesWritten: SIZE_T;
  begin
    var value: byte;

    if f then
      value := 0
    else
      value := 1;
    const LOGIN_OFFSET = $1AD1C84;      //wx 3.2.1   wx 3.2.1.154
    var DwCall := g_baseaddr + LOGIN_OFFSET;
    writeprocessmemory(GetCurrentProcess, Pointer(DwCall), @value, 1, lpNumberOfBytesWritten);
  end;
end;

function CheckLogin(): Boolean;
 //检查登录与否
begin
  var lpNumberOfBytesWritten: SIZE_T;

  var value: byte;


      //wx 3.2.1   wx 3.2.1.154
  var DwCall := g_baseaddr + $1AD1C84;
  ReadProcessMemory(GetCurrentProcess, Pointer(DwCall), @value, 1, lpNumberOfBytesWritten);

  if value = 1 then
    result := true
  else
    result := false;

end;


//跳转到二维码
procedure GotoQr();
  //跳转到二维码 CE 搜索      切换帐号 地址  od下内存写入断点
begin
  const WxGoToQrCode1 = $264830;				//跳转到二维码 1
  const WxGoToQrCode2 = $3ADE40;
  var dwCallAddr1 := g_baseaddr + WxGoToQrCode1;
  var dwCallAddr2 := g_baseaddr + WxGoToQrCode2;

  asm

        call    dwCallAddr1;
        mov     ecx, eax;
        call    dwCallAddr2;
  end;

  {
  var  wx_ver3.3.0
  str: string;
begin
  const WxGoToQrCode1 = $282160;				//跳转到二维码 1
  const WxGoToQrCode2 = $3db5f0;
  var dwCallAddr1 := g_baseaddr + WxGoToQrCode1;
  var dwCallAddr2 := g_baseaddr + WxGoToQrCode2;
  asm

        call    dwCallAddr1;
        mov     ecx, eax;
        call    dwCallAddr2;
  end;
end;}
end;

procedure SendMsg(wxid, txtData: string);
var
  wxidStruct: GeneralStruct;
  PwxidStruct: PAnsiChar;
  dataStruct: GeneralStruct;
  PdataStruct: PAnsiChar;
begin

  ZeroMemory(@SendMsgCallBuff1[0], 0);
  ZeroMemory(@SendMsgCallBuff2[0], 0);
  var dwSendCallAddr := g_baseaddr + $3B63B0;

  wxidStruct.pstr := Pointer((@wxid)^); // PChar(wxid);
  wxidStruct.ilen := wxid.Length;
  wxidStruct.iMaxLen := wxidStruct.iLen * 2;
  wxidStruct.full1 := 0;
  wxidStruct.full2 := 0;

  dataStruct.pstr := Pointer((@txtData)^);
  dataStruct.ilen := txtData.Length;
  dataStruct.iMaxLen := dataStruct.ilen * 2;
  dataStruct.full1 := 0;
  dataStruct.full2 := 0;

  PwxidStruct := @wxidStruct;
  PdataStruct := @dataStruct;

  asm
        push    1;
        lea     edi, SendMsgCallBuff2;
        push    edi;
        mov     ebx, PdataStruct;
        push    ebx;
        lea     ecx, SendMsgCallBuff1;
        mov     edx, PwxidStruct;
        call    dwSendCallAddr;
        add     esp, $C;
  end;
   {
  var
  idStruc: GeneralStruct;
  dataStruc: GeneralStruct;
  pwxid: PChar;
  sendData: PChar;

  wxid, pdata: WideString; dwSendCallAddr: DWORD;
begin
//  ZeroMemory(@buff[0], 0);
//  ZeroMemory(@buff2[0], 0);

  dwSendCallAddr := g_baseaddr + $3B63B0;
  wxid := Edit2.Text;
  pdata := edit1.text;
  idStruc.pstr :=PWideChar(wxid);//or Pointer((@wxid)^);
  idStruc.ilen := Length(wxid);
  idStruc.iMaxLen := idStruc.iLen * 2;
  idStruc.full1 := 0;
  idStruc.full2 := 0;

  dataStruc.pstr :=PWideChar(pdata);// Pointer((@pdata)^);
  dataStruc.ilen := Length(pdata);
  dataStruc.iMaxLen := dataStruc.ilen * 2;
  dataStruc.full1 := 0;
  dataStruc.full2 := 0;

  pwxid := @idStruc;
  sendData := @dataStruc;

  asm
  pushad
        push    1;
        lea     edi, buff2;
        push    edi;
         lea     ecx, buff;

        mov     ebx, sendData;
        push    ebx;

        mov     edx, pwxid;
        call    dwSendCallAddr;
        add     esp, $C;
        popad
  end  ;}
end;
  //=================================

initialization
  g_baseaddr := GetModuleHandle('WeChatWin.dll');

end.

