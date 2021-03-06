//
//  LHMenuScrollView.h
//  testNewUI
//
//  Created by Lin on 16/6/7.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LHMenuScrollViewDelegate <NSObject>

/** 回调点击菜单的标签的位置 */
- (void) tapMenuButtonAtIndex:(NSInteger) index;

@end

@interface LHMenuScrollView : UIScrollView

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, weak) id <LHMenuScrollViewDelegate> menuBarDelegate;


/** 顶部菜单按钮的宽度 */
@property (nonatomic,assign) CGFloat menuButtonWidth;
/** 随着滑动变化文字大小 */
- (void)changeTitlesFontSizeByScrollViewOffsetX:(CGFloat)contentOffsetX;
/** 滚动到特定的哪个页面 */
- (void)scrollToPage:(NSInteger)tag;

@end
