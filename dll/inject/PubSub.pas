unit PubSub;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, System.Messaging;

type
  //�����¼����Ϣ�ṹ��
  TChatMessageData = packed record
    dwtype: DWORD;				//��Ϣ����
    sztype, 		//��Ϣ����
    source,		//��Ϣ��Դ
    wxid, //΢��ID/ȺID
    wxname,		//΢������/Ⱥ����
    sender,		//��Ϣ������
    sendername,		//��Ϣ�������ǳ�
    content: string;	//��Ϣ����
  end;
//   �����б�

  TFriendList = packed record
    wxid: string;
    nickname: string;
    Remark:string;
    wxNumber:string;//΢�ź�
  end;





  TDefineNotify = record
    TxtData: string;
    MsgStruct: TChatMessageData;
    FriendStruct:TFriendList;
    protocol: Integer;    //90 �ı������б�         91 �ṹ�� ������Ϣ
  end;

var
  DefineNotify: TDefineNotify;

var
  message_bus: TMessageManager;

var
  SubscriptionId: Integer;

var
  MsgListener: TMessageListener;

implementation

initialization
  message_bus := TMessageManager.DefaultManager;

end.

