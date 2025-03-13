#ifndef WINDOWS_H
#define WINDOWS_H

/* Basic Windows types */
typedef unsigned int UINT;
typedef unsigned long DWORD;
typedef int BOOL;
typedef void *HANDLE;
typedef HANDLE HWND;
typedef HANDLE HINSTANCE;
typedef HANDLE HMENU;
typedef HANDLE HBRUSH;
typedef HANDLE HCURSOR;
typedef char *LPSTR;
typedef const char *LPCSTR;
typedef unsigned int WPARAM;
typedef long LPARAM;
typedef long LRESULT;
typedef struct tagMSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
} MSG;
typedef struct tagWNDCLASS {
    UINT style;
    LRESULT (*lpfnWndProc)(HWND, UINT, WPARAM, LPARAM);
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HBRUSH hbrBackground;
    LPCSTR lpszMenuName;
    LPCSTR lpszClassName;
    HCURSOR hCursor;
} WNDCLASS;

typedef struct tagPOINT {
    int x;
    int y;
} POINT;

/* Windows constants */
#define CALLBACK __stdcall

#define WS_OVERLAPPEDWINDOW 0x00CF0000
#define WS_VISIBLE 0x10000000
#define WS_CHILD 0x40000000
#define WS_TABSTOP 0x00010000
#define BS_DEFPUSHBUTTON 0x00000001
#define MB_OK 0x00000000
#define CW_USEDEFAULT ((int)0x80000000)
#define COLOR_WINDOW 5
#define IDC_ARROW ((HCURSOR)32512)

/* Windows messages */
#define WM_DESTROY 0x0002
#define WM_COMMAND 0x0111

/* Function declarations */
int MessageBox(HWND, LPCSTR, LPCSTR, UINT);
BOOL PostQuitMessage(int);
BOOL RegisterClass(const WNDCLASS *);
HWND CreateWindow(LPCSTR, LPCSTR, DWORD, int, int, int, int, HWND, HMENU, HINSTANCE, void *);
BOOL ShowWindow(HWND, int);
BOOL UpdateWindow(HWND);
BOOL GetMessage(MSG *, HWND, UINT, UINT);
BOOL TranslateMessage(const MSG *);
LRESULT DispatchMessage(const MSG *);
HCURSOR LoadCursor(HINSTANCE, LPCSTR);

#endif /* WINDOWS_H */
