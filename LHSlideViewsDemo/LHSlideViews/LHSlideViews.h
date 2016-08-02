//
//  LHSlideViews.h
//  testNewUI
//
//  Created by Lin on 16/6/7.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LHSlideViewsDelegate <NSObject>

/** 切换滚动式触发 */
- (void) lHSlideViewsVisiblePageViewController:(UIViewController *)pageViewController index:(NSInteger)index;

@end

@interface LHSlideViews : UIView

@property (nonatomic, weak) id <LHSlideViewsDelegate> delegate;

/** 顶部菜单标题 */
@property (nonatomic, strong) NSArray *titles;
/** 要显示子视图 */
@property (nonatomic, strong) NSMutableArray *pagesViews;

/** 滚动到指定的页面 */
- (void)scrollToPage:(NSInteger)tag;
/** 刷新数据 */
- (void)reloadData;

//-------- 可自定义属性 --------

/** 顶部菜单条的背景颜色 */
@property (nonatomic,strong) UIColor *menuBarBackgroudColor;
/** 顶部菜单条的高度 */
@property (nonatomic,assign) CGFloat menuBarHeight;
/** 顶部菜单按钮的宽度 */
@property (nonatomic,assign) CGFloat menuButtonWidth;

@end
