//
//  LHSlideViews.m
//  testNewUI
//
//  Created by Lin on 16/6/7.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import "LHSlideViews.h"
#import "LHMenuScrollView.h"

static const CGFloat kMenuBarHeight = 42.f;
static const CGFloat kMenuButtonWidth = 60.f;

@interface LHSlideViews() <UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate,LHMenuScrollViewDelegate>

@property(nonatomic, strong) LHMenuScrollView *menuBarScrollView;
@property(nonatomic, strong) UICollectionView *pagesCollectionView;

/** 当前显示的 cell indexPath */
@property (nonatomic,assign) NSInteger visibleIndex;

/** 过滤旋转屏幕时触发的滚动 */
@property (nonatomic,assign) BOOL isRotate;
/** 过滤跳转时，位于跳转的两个页面间未加载的页面，不让他们加载 */
@property (nonatomic,assign) BOOL isTapScroll;

/** 标记页面是否加载过 */
@property (nonatomic,strong) NSMutableArray *displayedCellArray;

@end

@implementation LHSlideViews
#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    _displayedCellArray = [NSMutableArray new];
    _menuBarHeight = kMenuBarHeight;
    _menuButtonWidth = kMenuButtonWidth;
    _menuBarBackgroudColor = [UIColor whiteColor];
    
    [self addSubview:self.menuBarScrollView];
    [self addSubview:self.pagesCollectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 过滤旋转屏幕时触发的滚动
    _isRotate = YES;
    if (_isRotate)
    {
        _menuBarScrollView.frame = CGRectMake(0, 0,  CGRectGetWidth(self.frame), self.menuBarHeight);
        _menuBarScrollView.backgroundColor = _menuBarBackgroudColor;
        _menuBarScrollView.menuButtonWidth = _menuButtonWidth;
        _pagesCollectionView.frame = CGRectMake(0, self.menuBarHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.menuBarHeight);
        
        // 旋转后调整 cell 到正确的位置
        [_pagesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_visibleIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        // 旋转时更新 layout
        UICollectionViewLayout *flowLayout = _pagesCollectionView.collectionViewLayout;
        [flowLayout invalidateLayout];
        _isRotate = NO;
    }
}

#pragma mark - action
/** 滚动到指定的页面 */
- (void)scrollToPage:(NSInteger)tag
{
    [self.menuBarScrollView scrollToPage:tag];
}

/** 刷新数据 */
- (void) reloadData
{
    [self.pagesCollectionView reloadData];
}

/** 获取当前View的控制器对象 */
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next);
    return nil;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titles.count;
}

/** 设置 cell 的大小 */
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.menuBarHeight);
}

/** 设置显示的 PageView */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 过滤跳转时，位于跳转的两个页面间未加载的页面，不让他们加载
    if (_isTapScroll && [_displayedCellArray[indexPath.row] integerValue] == 0) {
        return cell;
    }
    
    // 添加视图
    UIViewController *pageView =  _pagesViews[indexPath.row];
    pageView.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame),CGRectGetHeight(self.frame) - self.menuBarHeight);
    UIViewController *VC = [self getCurrentViewController];
    [VC addChildViewController:pageView];
    [cell.contentView addSubview:pageView.view];
    
    _isTapScroll = NO;
    
    return cell;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isRotate) // 过滤旋转屏幕时触发的滚动
    {
        // 改变标题大小
        [self.menuBarScrollView changeTitlesFontSizeByScrollViewOffsetX:scrollView.contentOffset.x];
        
        // 获取当前显示 cell 的 indexPath
        CGPoint point = [self convertPoint:_pagesCollectionView.center toView:_pagesCollectionView];
        NSIndexPath *indexPath = [_pagesCollectionView indexPathForItemAtPoint:point];
        if (indexPath.row != _visibleIndex) {
            self.visibleIndex = indexPath.row;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_isRotate) // 过滤旋转屏幕时触发的滚动
    {
        // 滚动顶部菜单
        CGFloat offsetX = scrollView.contentOffset.x * (_menuButtonWidth / self.frame.size.width);
        [self.menuBarScrollView scrollRectToVisible:CGRectMake(offsetX, 0, self.menuBarScrollView.frame.size.width, self.menuBarScrollView.frame.size.height) animated:YES];
    }
}

#pragma mark - LHMenuScrollViewDelegate
- (void)tapMenuButtonAtIndex:(NSInteger)index
{
    if ( labs(index - _visibleIndex) > 1) {
        _isTapScroll = YES;
    }
    
    // 标记为加载过
    _displayedCellArray[index] = @1;
    // 滚动到点击的相应的视图位置
    [_pagesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}

#pragma mark - getter & setter
- (UICollectionView *) pagesCollectionView
{
    if ( !_pagesCollectionView)
    {
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setMinimumLineSpacing:0];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _pagesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.menuBarHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.menuBarHeight) collectionViewLayout:flowLayout];
        _pagesCollectionView.dataSource = self;
        _pagesCollectionView.delegate = self;
        _pagesCollectionView.pagingEnabled = YES;
        _pagesCollectionView.backgroundColor = [UIColor clearColor];
        _pagesCollectionView.showsHorizontalScrollIndicator = NO;
        //注册Cell，必须要有
        [_pagesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
    }
    return _pagesCollectionView;
}

- (LHMenuScrollView *) menuBarScrollView
{
    if (!_menuBarScrollView) {
        _menuBarScrollView = [[LHMenuScrollView alloc] init];
        _menuBarScrollView.showsHorizontalScrollIndicator = NO;
        _menuBarScrollView.backgroundColor = _menuBarBackgroudColor ? :[UIColor whiteColor];
        _menuBarScrollView.menuButtonWidth = _menuButtonWidth;
        _menuBarScrollView.menuBarDelegate = self;
    }
    return _menuBarScrollView;
}

- (void) setTitles:(NSArray *)titles
{
    _titles = titles;
    self.menuBarScrollView.titles = self.titles;
}

- (void) setPagesViews:(NSMutableArray *)pagesViews
{
    _pagesViews = pagesViews;
    for (int i= 0; i < _pagesViews.count; i++ ) {
        
        [_displayedCellArray addObject: (i == 0? @1: @0)];
    }
}

- (void) setMenuBarHeight:(CGFloat)menuBarHeight
{
    _menuBarHeight = menuBarHeight;
    [self layoutSubviews];
}

- (void) setMenuButtonWidth:(CGFloat)menuButtonWidth
{
    _menuButtonWidth = menuButtonWidth;
    [self layoutSubviews];
}

- (void) setMenuBarBackgroudColor:(UIColor *)menuBarBackgroudColor
{
    _menuBarBackgroudColor = menuBarBackgroudColor;
    [self layoutSubviews];
}

- (void) setVisibleIndex:(NSInteger)visibleIndex
{
    _visibleIndex = visibleIndex;
    
    // 回调当前 Page
    [self.delegate lHSlideViewsVisiblePageViewController:_pagesViews[_visibleIndex] index:_visibleIndex];
}


@end
