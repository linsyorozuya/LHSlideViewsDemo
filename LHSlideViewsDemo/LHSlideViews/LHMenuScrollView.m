//
//  LHMenuScrollView.m
//  testNewUI
//
//  Created by Lin on 16/6/7.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import "LHMenuScrollView.h"

static const CGFloat kMenuTitleNormalFontSize = 14.f;           // 默认按钮未选中的字体大小
static const CGFloat kMenuTitleSelectedFontSize = 17.f;         // 默认按钮选中的字体大小
#define kScrollLineViewColor  [UIColor colorWithRed:0.094 green:0.780 blue:0.953 alpha:1.00]    // 下滑线的颜色
#define RGBAlpha(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

@implementation LHMenuScrollView
{
    UIView *_slideView;
    NSMutableArray *_menuButtonArray;
    UIButton *_firstButton;
    UIButton *_secondButton;
    
    NSInteger _selectedButtonIndex;
}

#pragma mark - 初始化
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (int i = 0; i < [_menuButtonArray count]; i++)
    {
        UIButton *menu_btn = _menuButtonArray[i];
        menu_btn.frame = CGRectMake(i* _menuButtonWidth , 0,  _menuButtonWidth, CGRectGetHeight(self.frame));
    }
    
    [self setContentSize:CGSizeMake(_menuButtonWidth * [_titles count], CGRectGetHeight(self.frame))];
}

#pragma setter
- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setContentSize:CGSizeMake(_menuButtonWidth * [_titles count], CGRectGetHeight(self.frame))];
    [self setupNavButtonByTitles];
}

- (void) setRootCollectionView:(UICollectionView *)pagesCollectionView
{
    _pagesCollectionView = pagesCollectionView;
}

- (void) setMenuButtonWidth:(CGFloat)menuButtonWidth
{
    _menuButtonWidth = menuButtonWidth;
    _slideView.frame = CGRectMake( _menuButtonWidth / 4 , CGRectGetHeight(self.frame)-3,  _menuButtonWidth/2, 2);
}

/** 初始化标题 */
- (void) setupNavButtonByTitles
{
    _menuButtonArray = [NSMutableArray new];
    for (int i = 0; i < [_titles count]; i++)
    {
        UIButton *menu_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        menu_btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        menu_btn.tag = i;
        [menu_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [menu_btn setTitle:_titles[i] forState:UIControlStateNormal];
        
        if(i==0)
        {
            [self changeColorForButton:menu_btn red:1];
            menu_btn.titleLabel.font = [UIFont boldSystemFontOfSize:kMenuTitleSelectedFontSize];
        }else
        {
            menu_btn.titleLabel.font = [UIFont boldSystemFontOfSize:kMenuTitleNormalFontSize];
            [self changeColorForButton:menu_btn red:0];
        }
        
        [menu_btn addTarget:self action:@selector(tap_menuBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menu_btn];
        [_menuButtonArray addObject:menu_btn];
    }
    
    // 初始化滑动条
    [self initSlideView];
}

/** 点击标签按钮 */
- (void)tap_menuBtn:(UIButton *)btn
{
    // 滚动到点击的相应的视图位置
    [self scrollToPage:(btn.tag)];
    _selectedButtonIndex = btn.tag;
}

/** 滚动到点击的相应的视图位置 */
- (void)scrollToPage:(NSInteger)tag
{
    // 滚动到点击的相应的视图位置
    [_pagesCollectionView scrollRectToVisible:CGRectMake(_pagesCollectionView.frame.size.width * tag, _pagesCollectionView.frame.origin.y, _pagesCollectionView.frame.size.width, _pagesCollectionView.frame.size.height) animated:YES];
    
    // 移动导航栏
    CGFloat menuOffsetX = self.frame.size.width * tag * (_menuButtonWidth / self.frame.size.width) - _menuButtonWidth;
    [self scrollRectToVisible:CGRectMake(menuOffsetX, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    _selectedButtonIndex = tag;
}

/** 初始化滑动条 */
-(void)initSlideView
{
    _slideView = [UIView new];
    _slideView.frame = CGRectMake( (_selectedButtonIndex + 1) * _menuButtonWidth / 4 , CGRectGetHeight(self.frame)-3,  _menuButtonWidth/2, 2);
    _slideView.backgroundColor = kScrollLineViewColor;
    [self addSubview:_slideView];
}

/** 随着滑动变化文字大小 */
- (void)changeTitlesFontSizeByScrollViewOffsetX:(CGFloat)contentOffsetX
{
    // 计算出 菜单滚动条 偏移的值
    CGFloat menuOffsetX = contentOffsetX * (_menuButtonWidth / self.frame.size.width);
    // 滑动横线
    [self animationWithView:_slideView andOffsetX:menuOffsetX + _menuButtonWidth/4 OffsetY:CGRectGetHeight(self.frame)-3 animationTime:0.3];
    
    // 滑动到第一个或者最后一个 不对 文字大小和颜色处理
    if (menuOffsetX < 0 || menuOffsetX > _menuButtonWidth *(_menuButtonArray.count -1)) return;
    
    // 恢复之前按钮的状态 （解决快速移动的时候 颜色和大小异常）
    [self resumeButtonNormalState];

    // 根据位移计算当前选择的按钮下标
    int buttonIndex = contentOffsetX / self.frame.size.width;

    // 根据位移计算出进度
    CGFloat percent = ( menuOffsetX - ( _menuButtonWidth * buttonIndex)) / _menuButtonWidth;
    
    // 变化按钮的文字大小和颜色
    _firstButton = _menuButtonArray[buttonIndex];
    [self updateButtonState:_firstButton percent:(1 - percent)];

    // 最后一个 防止越界
    if(buttonIndex +1 == _menuButtonArray.count) return;
    
    // 变化按钮的文字大小和颜色
    _secondButton = _menuButtonArray[buttonIndex + 1];
    [self updateButtonState:_secondButton percent:percent];

}

/** 变化按钮的文字大小和颜色 */
- (void) updateButtonState:(UIButton *)button percent:(CGFloat)percent
{
    CGFloat value = [self lerp:percent min:kMenuTitleNormalFontSize max:kMenuTitleSelectedFontSize];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:value];
    [self changeColorForButton:button red:percent];
}

/** 还原按钮正常状态 */
- (void) resumeButtonNormalState
{
    _firstButton.titleLabel.font = [UIFont boldSystemFontOfSize:kMenuTitleNormalFontSize];
    _secondButton.titleLabel.font = [UIFont boldSystemFontOfSize:kMenuTitleNormalFontSize];
    [self changeColorForButton:_firstButton red:0];
    [self changeColorForButton:_secondButton red:0];
}

/** 动画移动 */
- (void)animationWithView:(UIView*)view andOffsetX:(CGFloat)space_x OffsetY:(CGFloat)space_y animationTime:(CGFloat)time
{
    CGRect frame = view.frame;
    frame.origin.x = space_x;
    frame.origin.y = space_y;
    // 移动
    view.frame = frame;
}

/** 改变选中颜色 */
- (void)changeColorForButton:(UIButton *)btn red:(CGFloat)nRedPercent
{
    CGFloat redvalue = [self lerp:nRedPercent min:102 max:24];
    CGFloat greenvalue = [self lerp:nRedPercent min:102 max:199];
    CGFloat bluevalue = [self lerp:nRedPercent min:102 max:243];
    [btn setTitleColor:RGBAlpha(redvalue,greenvalue,bluevalue,1) forState:UIControlStateNormal];
}

/*0--1 : lerp( CGFloat percent, CGFloat x, CGFloat y ){ return x + ( percent * ( y - x ) ); };*/
- (CGFloat)lerp:(CGFloat)percent min:(CGFloat)nMin max:(CGFloat)nMax
{
    CGFloat result = nMin;
    result = nMin + percent * (nMax - nMin);
    result = [[NSString stringWithFormat:@"%.1f",result] floatValue];
    return result;
}

@end
