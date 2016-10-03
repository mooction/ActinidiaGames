
// SnakeView.h : CSnakeView ��Ľӿ�
#include "resource.h"
#include "atlimage.h"	// CImage
#include "time.h"

#pragma once

// ����
#define TOUP 1
#define TODOWN 2
#define TOLEFT 3
#define TORIGHT 4

// SnakeGo ���
#define GOFULLSCREEN 2
#define GOSUCCESS 1
#define GOGAMEOVER 0

// ��������
#define WID 18
#define HEI 10
#define FOOD -1
#define EMPTY 0

// ��Ϸѡ��
#define FAST 100
#define SLOW 200
#define DEFAULTLEN 4
#define FOODSIZE -3
#define TEXTSIZE 64

// ɫ��
#define LINECOLOR RGB(138,187,251)
#define SNAKECOLOR RGB(87,104,152)
#define BUMPCOLOR RGB(255,72,0)
#define FOODCOLOR RGB(61,89,171)
#define BACKGROUNDCOLOR RGB(205,220,255)
#define FONTCOLOR RGB(87,104,152)

// �ַ���
#define TEXTFONT "΢���ź�"
#define YOUWIN "��Ϸʤ��"
#define GAMEOVER "��Ϸ���� "
#define GAMEPAUSE "��Ϸ��ͣ"
#define IMGERROR "����ͼ����Դʧ��"
#define POINTSTR "������%d"

class CSnakeView
{

public:
	CSnakeView();
	~CSnakeView();
	void CreateGame(HWND _hwnd, HMODULE _hInstance);

private :
	HWND hwnd;
	HMODULE hInstance;
	void TransparentPNG(CImage *png);

public:

	int HeadPosX;				// ͷ��λ��
	int HeadPosY;
	int FoodPosX;				// ʳ��λ��
	int FoodPosY;
	int Board[WID + 1][HEI + 1];// ģ������
	int Direction;				// �˶�����
	int Mode;					// ��Ϸģʽ
	int EdgeWidth;				// �߿������߿�
	int SnakeLen;				// �ߵĳ���

	int Speed;					// �ߵ��ٶȣ���ʱ��Interval���ԣ�

	bool Eaten;					// �Ƿ���˶���
	bool isPause;				// �Ƿ��Ѿ���ͣ
	bool StartNew;				// �Ƿ���Ҫ������Ϸ
	bool Using;					// ��ֹ����ı䷽�����Bug

	// ���³�ʼ����Ϸ
	void GameStart();
	// ������Ϸ
	void GameOver();
	// ����EdgeWidth
	void CountEdgeWidth(const CRect DCRect);
	// �������ʳ��
	void SetFood();
	// ����ʳ��
	void DrawFood(HDC &compatibleDC);
	// ��������
	void DrawBoard(HDC &compatibleDC, const CRect DCRect);
	// ����Board�����ߵĻ���
	void DrawSnake(HDC &compatibleDC);
	// ����Board��Direction�������˶��ļ���
	int SnakeGo();
	// ����Ļ���������
	void PrintText(HDC &pDC, LPCTSTR lpText,WORD strlen);
	// �ڱ�������ʾ����
	void ShowPointOnTitle();
	// ������Ϸ�÷�
	int GamePoint();

public:
	void OnDraw(HDC &pDC);
	void OnTimer(UINT_PTR nIDEvent);
	void OnKeyDown(UINT nChar);

	void OnStart();
	void OnFastspeed();
	void OnSlowspeed();
};

