#pragma once
#pragma once
#include "stdafx.h"


#include <direct.h>
#include <stdlib.h>
#include <TlHelp32.h>
#include <stdio.h>

#include <string>
#pragma comment(lib,"advapi32")
//DWORD ProcessNameFindPID(const char* ProcessName);	//ͨ����������ȡ����ID
BOOL InjectDll(HANDLE& wxPid); //ע��dll
BOOL CheckIsInject(DWORD dwProcessid);	//���DLL�Ƿ��Ѿ�ע��