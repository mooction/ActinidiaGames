
#include "stdafx.h"
#include "SnakeView.h"


// SnakeView.cpp : CSnakeView ���ʵ��
//

// CSnakeView

CSnakeView::CSnakeView()
{
	// TODO:  �ڴ˴���ӹ������
}

void CSnakeView::CreateGame(HWND _hwnd, HMODULE _hInstance)
{
	hwnd = _hwnd;
	hInstance = _hInstance;
	Speed = FAST;					// �ߵ��ٶ�
	StartNew = true;
}

CSnakeView::~CSnakeView()
{

}


//////////////////////////////////////////////////////////////////////////
/// ����Դ�ļ��м���ͼƬ
/// @param [in] pImage ͼƬָ��
/// @param [in] nResID ��Դ��
/// @param [in] lpTyp ��Դ����
//////////////////////////////////////////////////////////////////////////
static bool LoadImageFromResource(HMODULE hInstance, IN CImage* pImage, IN UINT nResID, IN LPCWSTR lpTyp)
{
	if (pImage == NULL) return false;
	pImage->Destroy();
	// ������Դ
	HRSRC hRsrc = ::FindResource(hInstance, MAKEINTRESOURCE(nResID), lpTyp);
	if (hRsrc == NULL) return false;
	// ������Դ
	HGLOBAL hImgData = ::LoadResource(hInstance, hRsrc);
	if (hImgData == NULL)
	{
		::FreeResource(hImgData);
		return false;
	}
	// �����ڴ��е�ָ����Դ
	LPVOID lpVoid = ::LockResource(hImgData);
	LPSTREAM pStream = NULL;
	DWORD dwSize = ::SizeofResource(hInstance, hRsrc);
	HGLOBAL hNew = ::GlobalAlloc(GHND, dwSize);
	LPBYTE lpByte = (LPBYTE)::GlobalLock(hNew);
	::memcpy(lpByte, lpVoid, dwSize);
	// ����ڴ��е�ָ����Դ
	::GlobalUnlock(hNew);
	// ��ָ���ڴ洴��������
	HRESULT ht = CreateStreamOnHGlobal(hNew, TRUE, &pStream);
	if (ht != S_OK)
	{
		GlobalFree(hNew);
	}
	else
	{
		// ����ͼƬ
		pImage->Load(pStream);
		GlobalFree(hNew);
	}
	// �ͷ���Դ
	::FreeResource(hImgData);
	return true;
}

// PNG͸������
void CSnakeView::TransparentPNG(CImage *png)
{
	if (png->GetBPP() == 32) //ȷ�ϸ�ͼ�����Alphaͨ��
		for (int i = 0; i < png->GetWidth(); i++){
		for (int j = 0; j < png->GetHeight(); j++){
			unsigned char* pucColor = reinterpret_cast<unsigned char*>(png->GetPixelAddress(i, j));
			pucColor[0] = pucColor[0] * pucColor[3] / 255;
			pucColor[1] = pucColor[1] * pucColor[3] / 255;
			pucColor[2] = pucColor[2] * pucColor[3] / 255;
		}
		}
}


// CSnakeView ����

void CSnakeView::OnDraw(HDC &pDC)
{
	// TODO:  �ڴ˴�Ϊ����������ӻ��ƴ���
	CRect DCRect;
	GetClientRect(hwnd,&DCRect);
	
	if (StartNew){

		HBRUSH bgbr = CreateSolidBrush(BACKGROUNDCOLOR);		// ����ɫˢ��
		FillRect(pDC, DCRect, bgbr);							// ���ñ�����ɫ
		DeleteObject(bgbr);

		CImage img;
		if (!LoadImageFromResource(hInstance, &img, HelloSnake, _T("PNG"))){
			MessageBox(hwnd,_T(IMGERROR),NULL,NULL);
			return;
		}
		TransparentPNG(&img);
		int imgwidth = img.GetWidth();
		int imgheight = img.GetHeight();
		img.Draw(pDC,				// ��������ʱ�Ļ�ӭͼƬ
			(DCRect.Width() - imgwidth) / 2,
			(DCRect.Height() - imgheight) / 2,
			imgwidth,imgheight,
			0, 0, imgwidth, imgheight
			);

		// ValidateRect(hwnd, &DCRect);
		// ReleaseDC(hwnd, pDC);
		// EndPaint�����������Щ����
		return;
	}
	
	// ��Ϸ�Ѿ���ʼstartnew==false�������ػ�ʱ
	// һ����OnTimer���ã�Ҳ����ͨ���������Ŵ���

	CountEdgeWidth(DCRect);		// ���¼���߿�

	HDC compatibleDC = CreateCompatibleDC(NULL);		// ��������DC
	
	HBITMAP bmp = CreateCompatibleBitmap(pDC, DCRect.Width(), DCRect.Height());
	HBITMAP oldbmp = (HBITMAP)SelectObject(compatibleDC, bmp);		// ���ؼ���λͼ

	// �����Ļ ���ñ�����ɫ
	HBRUSH bgbr = CreateSolidBrush(BACKGROUNDCOLOR);
	FillRect(compatibleDC, DCRect, bgbr);
	DeleteObject(bgbr);
	
	DrawBoard(compatibleDC,DCRect);			// ��������
	DrawSnake(compatibleDC);				// ������
	DrawFood(compatibleDC);					// ����ʳ��
	if (isPause)
		PrintText(compatibleDC, _T(GAMEPAUSE), 4);	// ��ʾ��ͣ����
	
	// ��CompatibleDC������pDC
	BitBlt(pDC, 0, 0, DCRect.Width(), DCRect.Height(), compatibleDC, 0, 0, SRCCOPY);
	
	SelectObject(compatibleDC, oldbmp);
	DeleteObject(oldbmp);
	DeleteObject(bmp);
	DeleteDC(compatibleDC);	// ɾ����Դ

	// ValidateRect(hwnd, &DCRect);
	// ReleaseDC(hwnd, pDC);
	// ��Ϊ EndPaint �������Щ����
	return;
}

// ���������������ͷ
inline void DrawHeadToLeft(HDC pDC, int EdgeWidth, int x, int y){
	Rectangle(
		pDC,
		EdgeWidth * (x - 1) + x + EdgeWidth / 4,
		EdgeWidth * (y - 1) + y + EdgeWidth / 4,
		EdgeWidth * (x - 1) + x + EdgeWidth,
		EdgeWidth * (y - 1) + y + EdgeWidth * 3 / 4
		);
}

// �������������ҵ�ͷ
inline void DrawHeadToRight(HDC pDC, int EdgeWidth, int x, int y){
	Rectangle(
		pDC,
		EdgeWidth * (x - 1) + x - 1,
		EdgeWidth * (y - 1) + y + EdgeWidth / 4,
		EdgeWidth * (x - 1) + x + EdgeWidth * 3 / 4,
		EdgeWidth * (y - 1) + y + EdgeWidth * 3 / 4
		);
}

// �������������ϵ�ͷ
inline void DrawHeadToUp(HDC pDC, int EdgeWidth, int x, int y){
	Rectangle(
		pDC,
		EdgeWidth * (x - 1) + x + EdgeWidth / 4,
		EdgeWidth * (y - 1) + y + EdgeWidth / 4,
		EdgeWidth * (x - 1) + x + EdgeWidth * 3 / 4,
		EdgeWidth * (y - 1) + y + EdgeWidth
		);
}

// �������������µ�ͷ
inline void DrawHeadToDown(HDC pDC, int EdgeWidth, int x, int y){
	Rectangle(
		pDC,
		EdgeWidth * (x - 1) + x + EdgeWidth / 4,
		EdgeWidth * (y - 1) + y - 1,
		EdgeWidth * (x - 1) + x + EdgeWidth * 3 / 4,
		EdgeWidth * (y - 1) + y + EdgeWidth * 3 / 4
		);
}

// ���³�ʼ����Ϸ
void CSnakeView::GameStart()
{
	memset(Board, 0, sizeof(Board));	// ��ʼ������
	isPause = false;					// δ��ͣ״̬
	StartNew = false;
	Using = false;						// Ĭ��δռ�÷���
	Direction = TORIGHT;				// Ĭ�Ϸ�������
	Eaten = false;						// û��ʳ��

	SnakeLen = DEFAULTLEN;				// Ĭ�ϳ���
	HeadPosX = (WID + DEFAULTLEN) / 2;	// Ĭ���ߵ�λ��X
	HeadPosY = HEI / 2;					// Ĭ���ߵ�λ��Y
	for (int i = 0; i < SnakeLen; i++){
		Board[HeadPosX - i][HeadPosY] = i + 1;	// ���ó�ʼ��
	}

	SetFood();		// ����ʳ��

	SetTimer(hwnd,1, Speed, NULL);		// ������ʱ��
}


// ������Ϸ
void CSnakeView::GameOver()
{
	KillTimer(hwnd,1);

	HDC pDC = GetDC(hwnd);

	// ������ײЧ��
	
	HPEN pen = CreatePen(PS_SOLID, 1, SNAKECOLOR);
	HBRUSH br = CreateSolidBrush(BUMPCOLOR);
	HPEN pOldpen = (HPEN)SelectObject(pDC, pen);
	HBRUSH pOldbrush = (HBRUSH)SelectObject(pDC, br);
	switch (Direction)
	{
	case TOUP:
		DrawHeadToDown(pDC, EdgeWidth, HeadPosX, HeadPosY);
		break;
	case TODOWN:
		DrawHeadToUp(pDC, EdgeWidth, HeadPosX, HeadPosY);
		break;
	case TOLEFT:
		DrawHeadToRight(pDC, EdgeWidth, HeadPosX, HeadPosY);
		break;
	case TORIGHT:
		DrawHeadToLeft(pDC, EdgeWidth, HeadPosX, HeadPosY);
		break;
	default:
		break;
	}
	SelectObject(pDC, pOldpen);
	SelectObject(pDC, pOldbrush);
	DeleteObject(pOldpen);
	DeleteObject(pen);			// ɾ����Դ
	DeleteObject(pOldbrush);
	DeleteObject(br);			// ɾ����Դ
	
	// ������Ϸ
	wchar_t buf[10];
	wnsprintf(buf, 9 * sizeof(wchar_t), _T(POINTSTR), GamePoint());
	wchar_t buff[13];
	wnsprintf(buff, 12 * sizeof(wchar_t), _T("%s%7s"), _T(GAMEOVER),buf);
	PrintText(pDC, buff, 12);
	StartNew = true;			// �´�Ҫ���ո�ʼ��Ϸ

	CRect r;
	GetClientRect(hwnd, &r);
	ValidateRect(hwnd, r);
	ReleaseDC(hwnd,pDC);
}


// ����EdgeWidth
void CSnakeView::CountEdgeWidth(const CRect DCRect)
{
	if (DCRect.Width() * HEI / WID <= DCRect.Height())	// ���С�߶ȴ�
	{
		EdgeWidth = DCRect.Width() / WID - 1;
	}
	else// ��ȴ�߶�С
	{
		EdgeWidth = DCRect.Height() / HEI - 1;
	}
}


// �������һ��ʳ��
void CSnakeView::SetFood()
{
	int a, b;							// ��¼����
	srand((unsigned)time(NULL));		// �������
	if (SnakeLen < WID * HEI / 2){		// ���߳���Сʱ
		do{
			a = rand() % WID + 1;		// ���ɴ�1��WID�������
			b = rand() % HEI + 1;		// ���ɴ�1��HEI�������
		} while (Board[a][b] != EMPTY);
	}
	else{// ���ߺܳ�ʱ
		int R[WID * HEI / 2 + 1][2];	// �����λ������
		int t = 0;
		for (int i = 1; i <= WID; i++){
			for (int j = 1; j <= HEI; j++){
				if (Board[i][j] == EMPTY){	// Ѱ�����п�λ
					R[t][0] = i;
					R[t++][1] = j;
				}
			}
		}
		int r = rand() % t;				// ����0��t-1�������
		a = R[r][0];
		b = R[r][1];					// �õ���λ����
	}
	Board[a][b] = FOOD;					// ����ʳ��
	FoodPosX = a;
	FoodPosY = b;
	ShowPointOnTitle();					// ��ʾ����
}

// ����ʳ��
void CSnakeView::DrawFood(HDC &compatibleDC)
{
	CImage img;
	if (!LoadImageFromResource(hInstance,&img, FOODIMG, _T("PNG"))) {
		MessageBox(hwnd,_T(IMGERROR),NULL,NULL);		// ͼƬ����ʧ��
		return;
	}
	TransparentPNG(&img);				// ͸������
	img.Draw(							// ����ʳ��
		compatibleDC,
		EdgeWidth * (FoodPosX - 1) + FoodPosX - FOODSIZE,
		EdgeWidth * (FoodPosY - 1) + FoodPosY - FOODSIZE,
		EdgeWidth + 2 * (FOODSIZE),
		EdgeWidth + 2 * (FOODSIZE),
		0, 0, img.GetWidth(), img.GetHeight()
		);								// ��ʧ��
}

// ��������
void CSnakeView::DrawBoard(HDC &compatibleDC, const CRect DCRect)
{
	HPEN pen = CreatePen(PS_SOLID, 1, LINECOLOR);		// �߿�
	HPEN Oldpen = (HPEN)SelectObject(compatibleDC, pen);
	HBRUSH br = (HBRUSH)::GetStockObject(NULL_BRUSH);	// ����
	HBRUSH Oldbr = (HBRUSH)SelectObject(compatibleDC, br);
	for (int i = 0; i < WID; i++)											// �������
		Rectangle(compatibleDC, EdgeWidth * i + i, 0, EdgeWidth * (i + 1) + i + 2, EdgeWidth * HEI + HEI + 1);
	for (int i = 0; i < HEI; i++)											// �������
		Rectangle(compatibleDC, 0, EdgeWidth * i + i, EdgeWidth * WID + WID + 1, EdgeWidth*(i + 1) + i + 2);
	SelectObject(compatibleDC, Oldpen);
	SelectObject(compatibleDC, Oldbr);
	DeleteObject(Oldpen);
	DeleteObject(pen);
	DeleteObject(Oldbr);
	DeleteObject(br);
}

// ����Ļ���������
void CSnakeView::PrintText(HDC &pDC, LPCTSTR lpText, WORD strlen)
{
	HFONT fn;
	fn = CreateFont(TEXTSIZE, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS,
		CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, FF_SWISS, _T(TEXTFONT));	// ����iQuality�����Կ����
	HFONT oldfn = (HFONT)SelectObject(pDC,fn);
	SetBkMode(pDC, TRANSPARENT);
	SetTextColor(pDC, FONTCOLOR);
	TextOut(pDC, 150, 100, lpText, strlen);
	
	SelectObject(pDC,oldfn);
	DeleteObject(oldfn);
	DeleteObject(fn);

}

// �ڱ�������ʾ����
void CSnakeView::ShowPointOnTitle()
{
	wchar_t buf[10];
	wnsprintf(buf, 9 * sizeof(int), _T(POINTSTR), GamePoint());
	SetWindowText(hwnd,buf);
}

// ������Ϸ�÷�
int CSnakeView::GamePoint()
{
	return (SnakeLen - DEFAULTLEN) * 100;	// ÿ��һ��ʳ���100��
}

// ����Board�����ߵĻ���
void CSnakeView::DrawSnake(HDC &compatibleDC)
{
	HPEN pen = CreatePen(PS_SOLID, 1, SNAKECOLOR);
	HBRUSH br = CreateSolidBrush(SNAKECOLOR);
	HPEN Oldpen = (HPEN)SelectObject(compatibleDC, pen);
	HBRUSH Oldbrush = (HBRUSH)SelectObject(compatibleDC, br);

	int t = 1;				// ����
	int x = HeadPosX;		// ��ǰλ�õ�����ֵ
	int y = HeadPosY;
	int leftx, lefty;		// ��ߵ�����ֵ
	int rightx, righty;		// �ұߵ�����ֵ
	int upx, upy;			// �ϱߵ�����ֵ
	int downx, downy;		// �±ߵ�����ֵ
	while (t <= SnakeLen){

		// ��Ե����x
		switch (x)
		{
		case 1:				// ��Ļ�����
			leftx = WID;
			rightx = x + 1;
			break;
		case WID:			// ��Ļ���ұ�
			leftx = x - 1;
			rightx = 1;
			break;
		default:			// ��Ļ�м�
			leftx = x - 1;
			rightx = x + 1;
			break;
		}
		upx = x;			// ���±ߵ�xֵ����
		downx = x;

		// ��Ե����y
		switch (y)
		{
		case 1:				// ��Ļ���ϱ�
			upy = HEI;
			downy = y + 1;
			break;
		case HEI:			// ��Ļ���±�
			upy = y - 1;
			downy = 1;
			break;
		default:			// ��Ļ�м�
			upy = y - 1;
			downy = y + 1;
			break;
		}
		lefty = y;			// ���ұߵ�yֵ����
		righty = y;

		// ����һ�ص�λ�ý����ж�
		if ((Board[leftx][lefty] == (t - 1)) && (t != 1))	// �������һ��
		{
			DrawHeadToRight(compatibleDC, EdgeWidth, x, y);			// ���ҵ�ͷ
		}
		if ((Board[rightx][righty] == (t - 1)) && (t != 1))	// �ұ�����һ��
		{
			DrawHeadToLeft(compatibleDC, EdgeWidth, x, y);			// �����ͷ
		}
		if ((Board[upx][upy] == (t - 1)) && (t != 1))		// �ϱ�����һ��
		{
			DrawHeadToDown(compatibleDC, EdgeWidth, x, y);			// ���µ�ͷ
		}
		if ((Board[downx][downy] == (t - 1)) && (t != 1))	// �±�����һ��
		{
			DrawHeadToUp(compatibleDC, EdgeWidth, x, y);			// ���ϵ�ͷ
		}

		// ����һ�ص�λ�ý����ж�
		if (Board[leftx][lefty] == (t + 1))					// �������һ��
		{
			DrawHeadToRight(compatibleDC, EdgeWidth, x, y);			// ���ҵ�ͷ
			x = (x == 1) ? WID : x - 1;						// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[rightx][righty] == (t + 1))				// �ұ�����һ��
		{
			DrawHeadToLeft(compatibleDC, EdgeWidth, x, y);			// �����ͷ
			x = (x == WID) ? 1 : x + 1;						// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[upx][upy] == (t + 1))						// �ϱ�����һ��
		{
			DrawHeadToDown(compatibleDC, EdgeWidth, x, y);			// ���µ�ͷ
			y = (y == 1) ? HEI : y - 1;						// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[downx][downy] == (t + 1))					// �±�����һ��
		{
			DrawHeadToUp(compatibleDC, EdgeWidth, x, y);			// ���ϵ�ͷ
			y = (y == HEI) ? 1 : y + 1;						// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		// �������Ҷ��Ҳ�����һ�أ�˵���˴���ĩβ
		break;
	}
	SelectObject(compatibleDC, Oldpen);
	SelectObject(compatibleDC, Oldbrush);
	DeleteObject(Oldpen);
	DeleteObject(pen);
	DeleteObject(Oldbrush);
	DeleteObject(br);
}

// ����Board��Direction�������˶��ļ���
// ������Ҫ����ʵ�ʱ����False
int CSnakeView::SnakeGo()
{
	// ����
	int x = HeadPosX;		// ͷ��������ֵ
	int y = HeadPosY;
	int leftx, lefty;		// ��ߵ�����ֵ
	int rightx, righty;		// �ұߵ�����ֵ
	int upx, upy;			// �ϱߵ�����ֵ
	int downx, downy;		// �±ߵ�����ֵ
	bool HeadEatTail = false;	// �����β��ײ

	// ����ͷ��

	// ��Ե����x
	switch (x)
	{
	case 1:					// ��Ļ�����
		leftx = WID;
		rightx = x + 1;
		break;
	case WID:				// ��Ļ���ұ�
		leftx = x - 1;
		rightx = 1;
		break;
	default:				// ��Ļ�м�
		leftx = x - 1;
		rightx = x + 1;
		break;
	}
	upx = x;				// ���±ߵ�xֵ����
	downx = x;
	// ��Ե����y
	switch (y)
	{
	case 1:					// ��Ļ���ϱ�
		upy = HEI;
		downy = y + 1;
		break;
	case HEI:				// ��Ļ���±�
		upy = y - 1;
		downy = 1;
		break;
	default:				// ��Ļ�м�
		upy = y - 1;
		downy = y + 1;
		break;
	}
	lefty = y;				// ���ұߵ�yֵ����
	righty = y;

	// ������ͷ�ƶ�
	switch (Direction)
	{
	case TOLEFT:
		// ����һ�����������ж�
		switch (Board[leftx][lefty])
		{
		case EMPTY:							// �ո���
			Board[leftx][lefty] = 1;		// ����߷�������һ����ͷ
			break;
		case FOOD:							// ʳ��
			Board[leftx][lefty] = 1;		// ����߷�������һ����ͷ
			if (SnakeLen == WID * HEI - 1)	// �������������
			{
				GameOver();					// ����GameOver()������ʱ��
				return GOFULLSCREEN;		// �˳�����������ʵ�
			}
			Eaten = true;
			break;
		default:							// ��������
			if (Board[leftx][lefty] != SnakeLen)
			{
				GameOver();					// ��Ϸ����
				return GOGAMEOVER;			// ����
				break;
			}
			else
			{
				Board[leftx][lefty] = 1;	// ����β�Ͳ��㣬����߷�������һ����ͷ
				// �����ⲽ������β�͸����ˣ�����Ϊ�˱������ʱ��β�ʹ���һ
				HeadEatTail = true;
				break;
			}
		}
		HeadPosX = leftx;					// ������ͷλ��
		HeadPosY = lefty;
		break;
	case TORIGHT:
		// ����һ�����������ж�
		switch (Board[rightx][righty])
		{
		case EMPTY:							// �ո���
			Board[rightx][righty] = 1;		// ���ұ߷�������һ����ͷ
			break;
		case FOOD:							// ʳ��
			Board[rightx][righty] = 1;		// ���ұ߷�������һ����ͷ
			if (SnakeLen == WID * HEI - 1)	// �������������
			{
				GameOver();					// ����GameOver()������ʱ��
				return GOFULLSCREEN;		// �˳�����������ʵ�
			}
			Eaten = true;
			break;
		default:							// ��������
			if (Board[rightx][righty] != SnakeLen)
			{
				GameOver();					// ��Ϸ����
				return GOGAMEOVER;			// ����
				break;
			}
			else
			{
				Board[rightx][righty] = 1;	// ����β�Ͳ��㣬���ұ߷�������һ����ͷ
				// �����ⲽ������β�͸����ˣ�����Ϊ�˱������ʱ��β�ʹ���һ
				HeadEatTail = true;
				break;
			}
		}
		HeadPosX = rightx;					// ������ͷλ��
		HeadPosY = righty;
		break;
	case TOUP:
		// ����һ�����������ж�
		switch (Board[upx][upy])			// �Ը÷������һ������ж�
		{
		case EMPTY:							// �ո���
			Board[upx][upy] = 1;			// ���ϱ߷�������һ����ͷ
			break;
		case FOOD:							// ʳ��
			Board[upx][upy] = 1;			// ���ϱ߷�������һ����ͷ
			if (SnakeLen == WID * HEI - 1)	// �������������
			{
				GameOver();					// ����GameOver()������ʱ��
				return GOFULLSCREEN;		// �˳�����������ʵ�
			}
			Eaten = true;
			break;
		default:							// ��������
			if (Board[upx][upy] != SnakeLen)
			{
				GameOver();					// ��Ϸ����
				return GOGAMEOVER;			// ����
				break;
			}
			else
			{
				Board[upx][upy] = 1;		// ����β�Ͳ��㣬���ϱ߷�������һ����ͷ
				// �����ⲽ������β�͸����ˣ�����Ϊ�˱������ʱ��β�ʹ���һ
				HeadEatTail = true;
				break;
			}
		}
		HeadPosX = upx;						// ������ͷλ��
		HeadPosY = upy;
		break;
	case TODOWN:
		// ����һ�����������ж�
		switch (Board[downx][downy])		// �Ը÷������һ������ж�
		{
		case EMPTY:							// �ո���
			Board[downx][downy] = 1;		// ���±߷�������һ����ͷ
			break;
		case FOOD:							// ʳ��
			Board[downx][downy] = 1;		// ���±߷�������һ����ͷ
			if (SnakeLen == WID * HEI - 1)	// �������������
			{
				GameOver();					// ����GameOver()������ʱ��
				return GOFULLSCREEN;		// �˳�����������ʵ�
			}
			Eaten = true;
			break;
		default:							// ��������
			if (Board[downx][downy] != SnakeLen)
			{
				GameOver();					// ��Ϸ����
				return GOGAMEOVER;			// ����
				break;
			}
			else
			{
				Board[downx][downy] = 1;	// ����β�Ͳ��㣬���±߷�������һ����ͷ
				// �����ⲽ������β�͸����ˣ�����Ϊ�˱������ʱ��β�ʹ���һ
				HeadEatTail = true;
				break;
			}
		}
		HeadPosX = downx;					// ������ͷλ��
		HeadPosY = downy;
		break;
	default:
		return GOFULLSCREEN;				// û�з����ⲻ��ѧ���͵�������ʵ���
	}

	// ���ಿ�ֵ��ƶ���x,yΪԭ���ߵĵ�һ�أ����ߵĵڶ��أ�
	int t = 1;				// ԭ���ߵĵ�һ�أ����ߵĵڶ���

	while (t <= SnakeLen){
		// ��Ե����x
		switch (x)
		{
		case 1:				// ��Ļ�����
			leftx = WID;
			rightx = x + 1;
			break;
		case WID:			// ��Ļ���ұ�
			leftx = x - 1;
			rightx = 1;
			break;
		default:			// ��Ļ�м�
			leftx = x - 1;
			rightx = x + 1;
			break;
		}
		upx = x;			// ���±ߵ�xֵ����
		downx = x;

		// ��Ե����y
		switch (y)
		{
		case 1:				// ��Ļ���ϱ�
			upy = HEI;
			downy = y + 1;
			break;
		case HEI:			// ��Ļ���±�
			upy = y - 1;
			downy = 1;
			break;
		default:			// ��Ļ�м�
			upy = y - 1;
			downy = y + 1;
			break;
		}
		lefty = y;			// ���ұߵ�yֵ����
		righty = y;

		// ����һ�ص�λ�ý����ж�
		if (Board[leftx][lefty] == (t + 1))		// �������һ��
		{
			Board[x][y]++;						// ���ƶ�
			x = (x == 1) ? WID : x - 1;			// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[rightx][righty] == (t + 1))	// �ұ�����һ��
		{
			Board[x][y]++;						// ���ƶ�
			x = (x == WID) ? 1 : x + 1;			// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[upx][upy] == (t + 1))			// �ϱ�����һ��
		{
			Board[x][y]++;						// ���ƶ�
			y = (y == 1) ? HEI : y - 1;			// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		if (Board[downx][downy] == (t + 1))		// �±�����һ��
		{
			Board[x][y]++;						// ���ƶ�
			y = (y == HEI) ? 1 : y + 1;			// ��һ���ߵ�����
			t++;								// ����+1
			continue;							// ����
		}
		// ������ҵ���һ�أ�˵���˴�����ĩβ����ʱ x,y ������˸ղ��ҵ�����һ�ص�λ��
		// �������Ҷ��Ҳ�����һ�أ�˵���˴���ĩβ����ʱ x,y ��Ȼ�ǵ�ǰλ��
		if (Eaten){
			Board[x][y] = t + 1;				// β���ӳ�
			SnakeLen++;							// �߳�+1
			Eaten = false;
			SetFood();							// �ٷ���һ��ʳ��
		}
		else
		{
			if (HeadEatTail)
				Board[x][y] = t + 1;			// ��β��ӣ��ѱ�ͷ���ǵ���β�Ͳ���
			else
				Board[x][y] = EMPTY;			// ���ĩβ
		}
		break;
	}
	return GOSUCCESS;
}

//��Ϣ����

void CSnakeView::OnKeyDown(UINT nChar)
{
	// TODO:  �ڴ������Ϣ�����������/�����Ĭ��ֵ
	switch (nChar)
	{
	case VK_RETURN:
		nChar = VK_SPACE;						// �س�=�ո�
	case VK_SPACE:
		if (StartNew){
			GameStart();
		}
		else{
			if (isPause)
			{
				SetTimer(hwnd,1, Speed, NULL);
				isPause = false;				// ȡ����ͣ
			}
			else
			{
				KillTimer(hwnd,1);

				HDC pDC = ::GetDC(hwnd);
				PrintText(pDC, _T(GAMEPAUSE), 4);
				ReleaseDC(hwnd, pDC);

				isPause = true;					// ��ͣ��Ϸ
			}
		}
		break;
	case VK_UP:
		if (Direction != TODOWN && Using == false)
		{
			// �����߲���ͻȻ����,��ռ��ʱҲ���ܸ��ķ���
			Direction = TOUP;					// ��������
			Using = true;						// ��ʼռ��
		}
		break;
	case VK_DOWN:
		if (Direction != TOUP && Using == false)
		{
			// �����߲���ͻȻ����,��ռ��ʱҲ���ܸ��ķ���
			Direction = TODOWN;					// ��������
			Using = true;						// ��ʼռ��
		}
		break;
	case VK_LEFT:
		if (Direction != TORIGHT && Using == false)
		{
			// �����߲���ͻȻ����,��ռ��ʱҲ���ܸ��ķ���
			Direction = TOLEFT;					// ��������
			Using = true;						// ��ʼռ��
		}
		break;
	case VK_RIGHT:
		if (Direction != TOLEFT && Using == false)
		{
			// �����߲���ͻȻ����,��ռ��ʱҲ���ܸ��ķ���
			Direction = TORIGHT;				// ��������
			Using = true;						// ��ʼռ��
		}
		break;
	default:
		break;
	}
}

void CSnakeView::OnTimer(UINT_PTR nIDEvent)
{
	// TODO:  �ڴ������Ϣ�����������/�����Ĭ��ֵ
	Using = false;					// ���ռ��

	// ��ʱ��ֻ����������˶��ļ��㣬�����ڻ�ͼ��Ϣ���ػ�
	int result = SnakeGo();			// �����ߣ�����ʳ���Զ�SetFood��
	
	CRect DCRect;
	switch(result)
	{
	case GOSUCCESS:
		GetClientRect(hwnd, &DCRect);

		// �� InvalidateRect ���� WM_PAINT ��Ϣ
		// WM_PAINT ��Ϣ���� OnDraw ����ͼ
		InvalidateRect(hwnd, DCRect, FALSE);
		break;
	case GOGAMEOVER:
		// SnakeGo ����� GameOver
		break;
	case GOFULLSCREEN:
		MessageBox(hwnd, _T(YOUWIN), NULL, NULL);	// ����ʵ�
		break;
	}
}

// �˵�����ʼ/��ͣ
void CSnakeView::OnStart()
{
	// TODO:  �ڴ���������������
	if (StartNew){
		GameStart();
	}
	else{
		if (isPause)
		{
			SetTimer(hwnd,1, Speed, NULL);
			isPause = false;				// ȡ����ͣ
		}
		else
		{
			KillTimer(hwnd,1);

			HDC pDC = ::GetDC(hwnd);
			PrintText(pDC, _T(GAMEPAUSE), 4);
			ReleaseDC(hwnd, pDC);

			isPause = true;					// ��ͣ��Ϸ
		}
	}
}


void CSnakeView::OnFastspeed()
{
	// TODO:  �ڴ���������������
	CheckMenuItem(GetMenu(hwnd), FASTSPEED, MF_CHECKED);
	CheckMenuItem(GetMenu(hwnd), SLOWSPEED, MF_UNCHECKED);
	Speed = FAST;
	if (!StartNew){							// ��Ϸ״̬�£����ö�ʱ��
		KillTimer(hwnd,1);
		isPause = false;
		SetTimer(hwnd,1, Speed, NULL);
	}
}

void CSnakeView::OnSlowspeed()
{
	// TODO:  �ڴ���������������
	CheckMenuItem(GetMenu(hwnd), FASTSPEED, MF_UNCHECKED);
	CheckMenuItem(GetMenu(hwnd), SLOWSPEED, MF_CHECKED);
	Speed = SLOW;
	if (!StartNew){							// ��Ϸ״̬�£����ö�ʱ��
		KillTimer(hwnd,1);
		isPause = false;
		SetTimer(hwnd,1, Speed, NULL);
	}
}
