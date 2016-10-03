
// SnakeView.h : CSnakeView 类的接口
#include "resource.h"
#include "atlimage.h"	// CImage
#include "time.h"

#pragma once

// 方向
#define TOUP 1
#define TODOWN 2
#define TOLEFT 3
#define TORIGHT 4

// SnakeGo 结果
#define GOFULLSCREEN 2
#define GOSUCCESS 1
#define GOGAMEOVER 0

// 棋盘属性
#define WID 18
#define HEI 10
#define FOOD -1
#define EMPTY 0

// 游戏选项
#define FAST 100
#define SLOW 200
#define DEFAULTLEN 4
#define FOODSIZE -3
#define TEXTSIZE 64

// 色彩
#define LINECOLOR RGB(138,187,251)
#define SNAKECOLOR RGB(87,104,152)
#define BUMPCOLOR RGB(255,72,0)
#define FOODCOLOR RGB(61,89,171)
#define BACKGROUNDCOLOR RGB(205,220,255)
#define FONTCOLOR RGB(87,104,152)

// 字符串
#define TEXTFONT "微软雅黑"
#define YOUWIN "游戏胜利"
#define GAMEOVER "游戏结束 "
#define GAMEPAUSE "游戏暂停"
#define IMGERROR "调用图像资源失败"
#define POINTSTR "分数：%d"

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

	int HeadPosX;				// 头的位置
	int HeadPosY;
	int FoodPosX;				// 食物位置
	int FoodPosY;
	int Board[WID + 1][HEI + 1];// 模拟棋盘
	int Direction;				// 运动方向
	int Mode;					// 游戏模式
	int EdgeWidth;				// 边宽，不计线宽
	int SnakeLen;				// 蛇的长度

	int Speed;					// 蛇的速度（定时器Interval属性）

	bool Eaten;					// 是否吃了东西
	bool isPause;				// 是否已经暂停
	bool StartNew;				// 是否需要开新游戏
	bool Using;					// 防止过快改变方向产生Bug

	// 重新初始化游戏
	void GameStart();
	// 结束游戏
	void GameOver();
	// 计算EdgeWidth
	void CountEdgeWidth(const CRect DCRect);
	// 随机放置食物
	void SetFood();
	// 绘制食物
	void DrawFood(HDC &compatibleDC);
	// 绘制棋盘
	void DrawBoard(HDC &compatibleDC, const CRect DCRect);
	// 根据Board进行蛇的绘制
	void DrawSnake(HDC &compatibleDC);
	// 根据Board及Direction进行蛇运动的计算
	int SnakeGo();
	// 在屏幕上输出文字
	void PrintText(HDC &pDC, LPCTSTR lpText,WORD strlen);
	// 在标题栏显示分数
	void ShowPointOnTitle();
	// 计算游戏得分
	int GamePoint();

public:
	void OnDraw(HDC &pDC);
	void OnTimer(UINT_PTR nIDEvent);
	void OnKeyDown(UINT nChar);

	void OnStart();
	void OnFastspeed();
	void OnSlowspeed();
};

