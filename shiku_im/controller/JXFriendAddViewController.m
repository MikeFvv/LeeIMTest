//
//  JXFriendViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXFriendAddViewController.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "FMDatabase.h"
#import "JXProgressVC.h"
#import "JXTopSiftJobView.h"
#import "JXUserInfoVC.h"
#import "BMChineseSort.h"
#import "JXGroupViewController.h"
#import "OrganizTreeViewController.h"
#import "JXTabMenuView.h"
#import "JXPublicNumberVC.h"
#import "JXBlackFriendVC.h"
#import "JX_DownListView.h"
#import "JXNewRoomVC.h"
#import "JXNearVC.h"
#import "JXSearchUserVC.h"
#import "JXScanQRViewController.h"
#import "JXLabelVC.h"
#import "JXAddressBookVC.h"
#import "UIView+Frame.h"
#import "JXPayViewController.h"

#import "JXQRCodeViewController.h"
#import "JXFaceCreateRoomVC.h"

#define HEIGHT 56
#define IMAGE_HEIGHT  52  // 图片宽高
#define INSET_HEIGHT  10  // 图片文字间距


@interface JXFriendAddViewController ()<UITextFieldDelegate,JXSelectMenuViewDelegate>
@property (nonatomic, strong) JXUserObject * currentUser;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;


@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) UILabel *friendNewMsgNum;
@property (nonatomic, strong) UILabel *abNewMsgNum;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) CGFloat btnHeight;  // 按钮的真实高度

@end

@implementation JXFriendAddViewController

#define HEIGHT 56
#define MY_INSET  0  // 每行左右间隙


- (instancetype)init{
    
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        [self createHeadAndFoot];
        
        NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        // lewis
//        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(16, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/4, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
        titleL.textAlignment = NSTextAlignmentCenter;
        
        titleL.text = @"添加朋友";
        titleL.font = [UIFont boldSystemFontOfSize:18];
        [self.tableHeader addSubview: titleL];

    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = HEXCOLOR(0xf0eff4);
    
    JXImageView* iv;
    int w = JX_SCREEN_WIDTH;
    int h = 8;
    
    iv = [self createButton:@"搜索账号/手机号/ID" drawTop:NO drawBottom:NO icon: @"message_search_publicNumber" isWebImage:NO click:@selector(addFriendAction) tag:0];
    iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);

    h += iv.frame.size.height;
    
    
//    iv = [self createButton:Localized(@"JX_MyQRImage") drawTop:NO drawBottom:NO icon: @"" isWebImage:NO click:@selector(showBarcodeAction) tag:1];
//    iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);
//
//    UIImageView * qrView = [[UIImageView alloc] init];
//    qrView.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-30, 10, 30, 30);
//    qrView.image = [UIImage imageNamed:@"qrcodeImage"];
//    [iv addSubview:qrView];
//    iv.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);
    [btn setImage:[UIImage imageNamed:@"qrcodeImage"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:Localized(@"JX_MyQRImage") forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, - btn.imageView.image.size.width, 0, btn.imageView.image.size.width)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
    [btn addTarget:self action:@selector(showBarcodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:btn];
    
    h+=iv.frame.size.height;
    
//    iv = [self createButton:@"面对面建群" drawTop:YES drawBottom:YES icon: @"message_mianduimian_black" isWebImage:NO click:@selector(createGroupAction) tag:2];
//    iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);
//
//    h += iv.frame.size.height;
    
    
    iv = [self createButton:Localized(@"JX_saoyisao") drawTop:NO drawBottom:YES icon: @"messaeg_scnning_black" isWebImage:NO click:@selector(showScanViewAction) tag:3];
    iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);

    h += iv.frame.size.height;
    
    
    iv = [self createButton:@"黑名单" drawTop:NO drawBottom:YES icon: @"messaeg_black_list_black" isWebImage:NO click:@selector(showBlackListAction) tag:4];
    iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);

    h += iv.frame.size.height;
    
}

- (JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon isWebImage:(BOOL)isWebImage click:(SEL)click tag:(NSInteger)tag{
    
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    btn.tag = tag;
    
  
    
    
    [self.tableView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];

    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT-20)/2, 21, 21)];
        if (isWebImage) {
              [iv sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"酷聊120"]];
          }
        else {
            iv.image = [UIImage imageNamed:icon];
        }
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.3,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
//    
//    if(click){
//        UIImageView* iv;
//        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, 16, 20, 20)];
//        iv.image = [UIImage imageNamed:@"set_list_next"];
//        [btn addSubview:iv];
//        
//    }
    return btn;
}

-(void)addFriendAction {
    JXSearchUserVC* vc = [JXSearchUserVC alloc];
    vc.delegate  = self;
    vc.didSelect = @selector(doSearch:);
    vc.type = JXSearchTypeUser;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)doSearch:(searchData*)p{
    
    JXNearVC *nearVC = [[JXNearVC alloc]init];
    nearVC.isSearch = YES;
    [g_navigation pushViewController:nearVC animated:YES];
    [nearVC doSearch:p];
}

-(void)showBarcodeAction {
    JXQRCodeViewController * qrVC = [[JXQRCodeViewController alloc] init];
        qrVC.type = QRUserType;
        qrVC.userId = g_server.myself.userId;
        qrVC.account = g_server.myself.account;
        qrVC.nickName = g_server.myself.userNickname;
    //    [g_window addSubview:qrVC.view];
        [g_navigation pushViewController:qrVC animated:YES];
}

-(void)createGroupAction{
    JXFaceCreateRoomVC *vc = [[JXFaceCreateRoomVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)showScanViewAction{
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
    JXScanQRViewController * scanVC = [[JXScanQRViewController alloc] init];
    
    [g_navigation pushViewController:scanVC animated:YES];
}

-(void)showBlackListAction{
    JXBlackFriendVC *vc = [[JXBlackFriendVC alloc] init];
    vc.title = Localized(@"JX_BlackList");
    [g_navigation pushViewController:vc animated:YES];
}
@end
