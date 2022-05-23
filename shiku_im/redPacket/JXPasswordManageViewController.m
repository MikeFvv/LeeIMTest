//
//  JXPasswordManageViewController.m
//  shiku_im
//
//  Created by 胡勇 on 2020/2/4.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXPasswordManageViewController.h"
#import "JXPayPasswordVC.h"
#import "forgetPwdVC.h"

@interface JXPasswordManageViewController ()



@end

@implementation JXPasswordManageViewController

#define HEIGHT 56
#define MY_INSET 10

- (instancetype)init{
    
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = @"支付密码管理";
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    
    self.tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    self.tableBody.alwaysBounceVertical = YES;
    
    CGFloat h = 10;
   
    JXImageView *changePayPassword = [self createButton:@"修改支付密码" drawTop:YES drawBottom:NO icon:nil click:@selector(changePasswordAction)];
    changePayPassword.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
    [self.tableBody addSubview:changePayPassword];
    
    h += HEIGHT;
    if ([g_server.myself.isPayPassword boolValue]) {
        JXImageView *forgetPayPassword = [self createButton:@"忘记支付密码" drawTop:YES drawBottom:YES icon:nil click:@selector(forgetPasswordAction)];
        forgetPayPassword.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
        [self.tableBody addSubview:forgetPayPassword];
    }

}

- (void)changePasswordAction {
    
    JXPayPasswordVC * PayVC = [JXPayPasswordVC alloc];
       if ([g_server.myself.isPayPassword boolValue]) {
           PayVC.type = JXPayTypeInputPassword;
       }else {
           PayVC.type = JXPayTypeSetupPassword;
       }
       PayVC.enterType = JXEnterTypeDefault;
       PayVC = [PayVC init];
       [g_navigation pushViewController:PayVC animated:YES];
}

- (void)forgetPasswordAction{
    if ([g_server.myself.isPayPassword boolValue]) {
            forgetPwdVC* vc = [[forgetPwdVC alloc] init];
            vc.state = 2;
        //    [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
    }else{
        
        [self changePasswordAction];
    }

    
}

- (JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click{
    
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
//    p.delegate = self;
//    p.didTouch = click;
    [btn addSubview:p];

    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT - 25) / 2, 25, 25)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }
    else {
        p.frame = CGRectMake(20, 0, self_width-35-20-5, HEIGHT);
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
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, (HEIGHT - 20) / 2, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        
    }
    return btn;
}


@end
