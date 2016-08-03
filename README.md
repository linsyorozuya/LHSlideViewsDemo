# LHSlideViewsDemo

UICollectionView 实现简单带标签栏滚动控件

![image](https://github.com/linsyorozuya/LHSlideViewsDemo/blob/master/2016-08-02%2016_33_40.gif)

#### 使用方法

      //初始化数据 datasourse
       NSMutableArray *titleArray = [[NSMutableArray alloc]initWithObjects:@"全部",@"语文",@"数学",@"英语",@"物理",@"化学",@"生物",@"政治",@"历史",@"地理",@"学法", nil];
       NSMutableArray *pageViewsArray = [NSMutableArray new];

       // 获取内容数据
       for (int i = 0; i<titleArray.count; i++)
       {
           UIViewController *pageVC = [UIViewController new];
           pageVC.view.backgroundColor = [self randomColor];
        
          [pageViewsArray addObject:pageVC];
       }
       
       // 初始化 slideViews
       self.slideViews.titles = titleArray;
       self.slideViews.pagesViews = pageViewsArray;
       [self.view addSubview:self.slideViews];
       [self.slideViews reloadData];
       
       
       
####标签栏试着改成 UICollectionView 来实现，也许会好点 =。=
