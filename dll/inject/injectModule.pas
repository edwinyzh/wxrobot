unit injectModule;

interface
  //ȡ�ú����б�

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, tlhelp32,
  PsAPI, Vcl.StdCtrls, Vcl.ExtCtrls, u_debug, DDetours, Method2,
  System.Messaging, Generics.Collections, wxCore;

var
  OldFuncAddr: dword;
  OldFunc: pointer;   //  OldFuncAddr   call OldFunc
  OldInstructionBackUp: array[0..4] of Byte; //��ָ���
  JumpBackAddress: dword;
  str: string;
  ddd: PChar;
  mystr: string;
  data_base: dword;

implementation

uses
  Method1, Method3, PubSub;

procedure show_item_data();
var
  len: Cardinal;
  p1: Nativeuint;
  pwxid: pchar;
var
  Message: TMessage;
begin



//    form2.ListBox1.Items.Insert(0, v.ToString);
  len := PDWORD(data_base + 4 + 4 + 4)^;   // wxid_len
//  len := PDWORD(v + 4 + 4 + 4)^;   // wxid_len
//
  p1 := data_base + 4 + 4;
  pwxid := PChar(Pointer((@p1)^)^);
//  form2.ListBox1.Items.Insert(0, '--->wxid' + mygod);

  p1 := data_base + $64;
  var nickname := PChar(Pointer((@p1)^)^);

  var sum_vv := pwxid + ' ' + nickname;
//  debug.Show(sum_vv);
//listbox1.Items.IndexOf('�ظ����ַ�')=   -1     ��ʾû���ظ�
//  if  form2.ListBox1.Items.IndexOf(sum_vv)=-1 then
//       form2.ListBox1.Items.Insert(0, sum_vv);
//    form2.ListBox1.Items.Insert(0, len.ToString);

  ttx.bb := sum_vv;
  ttx.i := 90;
  Message := TMessage<tx>.Create(ttx);
  message_bus.SendMessage(nil, Message, True);
end;

procedure NewFuncAddr();
asm
        pushad
        mov     data_base, esi
        call    show_item_data
        popad
        call    OldFunc;
        jmp     JumpBackAddress
end;

procedure UnHook;
  //�ָ�ԭָ��
begin
  var xv: SIZE_T;
  WriteProcessMemory(GetCurrentProcess(), Pointer(OldFuncAddr), @OldInstructionBackUp, 5, xv);
end;

initialization
  g_baseaddr := GetModuleHandle('WeChatWin.dll');
  OldFuncAddr := g_baseaddr + $5244a8;

  OldFunc := Pointer(g_baseaddr + $64550);

  JumpBackAddress := OldFuncAddr + SizeOf(TInstruction);  // +5  ���ص�ַ����ִ��
//  ����ԭ���ĵ�ַָ��     ��ԭʹ��
  CopyMemory(@OldInstructionBackUp, Pointer(OldFuncAddr), 5);  //memcpy


  f3(@NewFuncAddr, Pointer(OldFuncAddr));

end.

