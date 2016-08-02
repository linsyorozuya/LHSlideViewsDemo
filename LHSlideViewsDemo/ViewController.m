//
//  ViewController.m
//  LHSlideViewsDemo
//
//  Created by Lin on 16/8/2.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import "ViewController.h"
#import "LHSlideViews.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet LHSlideViews *slideViews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
}

- (UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
