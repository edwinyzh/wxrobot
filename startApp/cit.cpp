#include "stdafx.h"

#include "cit.h"
#include <direct.h>
#include <stdlib.h>
#include <TlHelp32.h>
#include <stdio.h>

#include <string>
#pragma comment(lib,"advapi32")


#define WECHAT_PROCESS_NAME "WeChat.exe"
#define DLLNAME "WxInterface.dll"

using namespace std;

wstring GetAppRegeditPath(wstring strAppName)
{
	//������ر���
	HKEY hKey;
	wstring strAppRegeditPath = L"";
	TCHAR szProductType[MAX_PATH];
	memset(szProductType, 0, sizeof(szProductType));

	DWORD dwBuflen = MAX_PATH;
	LONG lRet = 0;

	//�����Ǵ�ע���,ֻ�д򿪺��������������
	lRet = RegOpenKeyEx(HKEY_CURRENT_USER, //Ҫ�򿪵ĸ���
		strAppName.c_str(), //Ҫ�򿪵����Ӽ�
		0, //���һ��Ϊ0
		KEY_QUERY_VALUE, //ָ���򿪷�ʽ,��Ϊ��
		&hKey); //�������ؾ��

	if (lRet != ERROR_SUCCESS) //�ж��Ƿ�򿪳ɹ�
	{
		return strAppRegeditPath;
	}
	else
	{
		//���濪ʼ��ѯ
		lRet = RegQueryValueEx(hKey, //��ע���ʱ���صľ��
			TEXT("Wechat"), //Ҫ��ѯ������,��ѯ�������װĿ¼������
			NULL, //һ��ΪNULL����0
			NULL,
			(LPBYTE)szProductType, //����Ҫ�Ķ�����������
			&dwBuflen);

		if (lRet != ERROR_SUCCESS) //�ж��Ƿ��ѯ�ɹ�
		{
			return strAppRegeditPath;
		}
		else
		{
			RegCloseKey(hKey);

			strAppRegeditPath = szProductType;

			int nPos = strAppRegeditPath.find('-');

			if (nPos >= 0)
			{
				wstring sSubStr = strAppRegeditPath.substr(0, nPos - 1);
				//wstring sSubStr = strAppRegeditPath.left(nPos - 1);//����$,�������ʱnPos+1

				strAppRegeditPath = sSubStr;
			}
		}
	}
	return strAppRegeditPath;
}
wstring GetAppRegeditPath2(wstring strAppName)
{
	//������ر���
	HKEY hKey;
	wstring strAppRegeditPath = L"";
	TCHAR szProductType[MAX_PATH];
	memset(szProductType, 0, sizeof(szProductType));

	DWORD dwBuflen = MAX_PATH;
	LONG lRet = 0;

	//�����Ǵ�ע���,ֻ�д򿪺��������������
	lRet = RegOpenKeyEx(HKEY_CURRENT_USER, //Ҫ�򿪵ĸ���
		strAppName.c_str(), //Ҫ�򿪵����Ӽ�
		0, //���һ��Ϊ0
		KEY_QUERY_VALUE, //ָ���򿪷�ʽ,��Ϊ��
		&hKey); //�������ؾ��

	if (lRet != ERROR_SUCCESS) //�ж��Ƿ�򿪳ɹ�
	{
		return strAppRegeditPath;
	}
	else
	{
		//���濪ʼ��ѯ
		lRet = RegQueryValueEx(hKey, //��ע���ʱ���صľ��
			TEXT("InstallPath"), //Ҫ��ѯ������,��ѯ�������װĿ¼������
			NULL, //һ��ΪNULL����0
			NULL,
			(LPBYTE)szProductType, //����Ҫ�Ķ�����������
			&dwBuflen);

		if (lRet != ERROR_SUCCESS) //�ж��Ƿ��ѯ�ɹ�
		{
			return strAppRegeditPath;
		}
		else
		{
			RegCloseKey(hKey);
			strAppRegeditPath = szProductType;

		}
	}
	return strAppRegeditPath;
}

BOOL InjectDll(HANDLE& wxPid)
{
	//��ȡ��ǰ����Ŀ¼�µ�dll
	char szPath[MAX_PATH] = { 0 };
	char* buffer = NULL;
	if ((buffer = _getcwd(NULL, 0)) == NULL)
	{
		MessageBoxA(NULL, "��ȡ��ǰ����Ŀ¼ʧ��", "����", 0);
		return FALSE;
	}
	sprintf_s(szPath, "%s\\%s", buffer, DLLNAME);
	//��ȡ΢��Pid


	HWND h1 = FindWindow(L"WeChatLoginWndForPC", L"΢��");

	DWORD dwPid;
	GetWindowThreadProcessId(h1, &dwPid);


	if ((dwPid == 0) || (h1 == 0))
	{
		wstring  wxStrAppName = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
		wstring szProductType = GetAppRegeditPath(wxStrAppName);

		if (szProductType.length() < 5)
		{
			wxStrAppName = TEXT("Software\\Tencent\\WeChat");
			szProductType = GetAppRegeditPath2(wxStrAppName);
			szProductType.append(L"\\WeChat.exe");
		}
		STARTUPINFO si;
		PROCESS_INFORMATION pi;
		ZeroMemory(&si, sizeof(si));
		si.cb = sizeof(si);
		ZeroMemory(&pi, sizeof(pi));

		si.dwFlags = STARTF_USESHOWWINDOW;// ָ��wShowWindow��Ա��Ч
		si.wShowWindow = TRUE;          // �˳�Ա��ΪTRUE�Ļ�����ʾ�½����̵������ڣ�
									   // ΪFALSE�Ļ�����ʾ

		CreateProcessW(szProductType.c_str(), NULL, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);

		HWND  hWechatMainForm = NULL;
		//WeChatLoginWndForPC
		while (NULL == hWechatMainForm)
		{
			hWechatMainForm = FindWindow(TEXT("WeChatLoginWndForPC"), NULL);
			Sleep(500);
		}
		if (NULL == hWechatMainForm)
		{
			return FALSE;
		}
		dwPid = pi.dwProcessId;
		wxPid = pi.hProcess;

	}
	//���dll�Ƿ��Ѿ�ע��
	if (CheckIsInject(dwPid))
	{
		//�򿪽���
		HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPid);
		if (hProcess == NULL)
		{
			MessageBoxA(NULL, "���̴�ʧ��", "����", 0);
			return FALSE;
		}
		//��΢�Ž����������ڴ�
		LPVOID pAddress = VirtualAllocEx(hProcess, NULL, MAX_PATH, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
		if (pAddress == NULL)
		{
			MessageBoxA(NULL, "�ڴ����ʧ��", "����", 0);
			return FALSE;
		}
		//д��dll·����΢�Ž���
		if (WriteProcessMemory(hProcess, pAddress, szPath, MAX_PATH, NULL) == 0)
		{
			MessageBoxA(NULL, "·��д��ʧ��", "����", 0);
			return FALSE;
		}

		//��ȡLoadLibraryA������ַ
		FARPROC pLoadLibraryAddress = GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA");
		if (pLoadLibraryAddress == NULL)
		{
			MessageBoxA(NULL, "��ȡLoadLibraryA������ַʧ��", "����", 0);
			return FALSE;
		}
		//Զ���߳�ע��dll
		HANDLE hRemoteThread = CreateRemoteThread(hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)pLoadLibraryAddress, pAddress, 0, NULL);
		if (hRemoteThread == NULL)
		{
			MessageBoxA(NULL, "Զ���߳�ע��ʧ��", "����", 0);
			return FALSE;
		}

		CloseHandle(hRemoteThread);
		CloseHandle(hProcess);
	}
	else
	{
		MessageBoxA(NULL, "dll�Ѿ�ע�룬�����ظ�ע��", "��ʾ", 0);
		return FALSE;
	}

	return TRUE;
}

BOOL CheckIsInject(DWORD dwProcessid)
{
	HANDLE hModuleSnap = INVALID_HANDLE_VALUE;
	//��ʼ��ģ����Ϣ�ṹ��
	MODULEENTRY32 me32 = { sizeof(MODULEENTRY32) };
	//����ģ����� 1 �������� 2 ����ID
	hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, dwProcessid);
	//��������Ч�ͷ���false
	if (hModuleSnap == INVALID_HANDLE_VALUE)
	{
		MessageBoxA(NULL, "����ģ�����ʧ��", "����", MB_OK);
		return FALSE;
	}
	//ͨ��ģ����վ����ȡ��һ��ģ�����Ϣ
	if (!Module32First(hModuleSnap, &me32))
	{
		MessageBoxA(NULL, "��ȡ��һ��ģ�����Ϣʧ��", "����", MB_OK);
		//��ȡʧ����رվ��
		CloseHandle(hModuleSnap);
		return FALSE;
	}
	do
	{
		if (me32.szModule == L"WeChatHelper.dll")
		{
			return FALSE;
		}

	} while (Module32Next(hModuleSnap, &me32));
	return TRUE;
}

