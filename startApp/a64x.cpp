// a64x.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include<iostream>
#include <stdio.h>
#include "cit.h"
#undef   UNICODE 
#include <sysinfoapi.h>
#include <TlHelp32.h>
#include <string>
#include <io.h>
#include<cstring>
#include<tchar.h>
#include <atlstr.h>

using namespace std;

HANDLE wxPid = NULL;		//΢�ŵ�PID
//************************************************************
// ��������: InjectDll
// ����˵��: ע��DLL
// ��    ��: GuiShou
// ʱ    ��: 2019/6/30
// ��    ��: void
// �� �� ֵ: void
//************************************************************


int main()
{



	if (InjectDll(wxPid) == FALSE)
	{
		ExitProcess(-1);
	}




    return 0;
}

