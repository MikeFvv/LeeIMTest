//
//  FindViewController.m
//  shiku_im
//
//  Created by Admin on 2022/1/13.
//  Copyright © 2022 Reese. All rights reserved.
//

#import "FindViewController.h"
#import "SLPrefixHeader.pch"



@interface FindViewController ()<UITableViewDataSource,UITableViewDelegate>
///
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (self.navigationController) {
        NSLog(@"1");
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (self.navigationController.navigationBar.translucent) {
        self.navigationController.navigationBar.translucent = NO; // 设置导航栏是否透明
    }
//
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.navigationBar.translucent = YES; // 设置导航栏是否透明
}

- (void)createUI {
    self.view.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:self.tableView];
}



#pragma mark -  UITableView 初始化
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-TabbarHeight) style:UITableViewStylePlain];
        
        //        _tableView.backgroundColor = [UIColor whiteColor];
        //        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight=50;   //设置每一行的高度
        //        _tableView.scrollEnabled = NO;  //设置tableview 不能滚动
    }
    
    return _tableView;
}






#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"app_cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    UIImage *image = nil;
    if (indexPath.row == 0) {
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        image = [UIImage imageNamed:icon];
        
        cell.textLabel.text = XL_APP_NAME;
        
    } else if (indexPath.row == 1) {
        image = [UIImage imageNamed:@"shenghuoquan"];
        
        cell.textLabel.text = Localized(@"JXUserInfoVC_Space");
    } else if (indexPath.row == 2) {
        image = [UIImage imageNamed:@"saoyisao"];
        cell.textLabel.text = Localized(@"JX_saoyisao");
    }
    
    
//    cell.detailTextLabel.text = app.developerName;
    
   
    cell.imageView.image = image;
    
    cell.imageView.layer.cornerRadius = image.size.width*0.2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    cell.imageView.layer.borderWidth = 0.5;
    cell.imageView.layer.shouldRasterize = YES;
    cell.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;  // 右箭头
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
    } else if (indexPath.row == 1) {
        
    } else if (indexPath.row == 2) {
       
    }
    
}

@end
