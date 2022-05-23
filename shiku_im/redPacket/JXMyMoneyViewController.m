//
//  JXMyMoneyViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXMyMoneyViewController.h"
#import "UIImage+Color.h"
#import "JXCashWithDrawViewController.h"
#import "JXRechargeViewController.h"
#import "JXRecordCodeVC.h"
#import "JXMoneyMenuViewController.h"
#import "JXPayPasswordVC.h"
#import "JXAddBankCardAndAlipayVC.h"
#import "UIImage-Extensions.h"
#import "JXPasswordManageViewController.h"

@interface JXMyMoneyViewController ()

@property (nonatomic, strong) UIButton * listButton;

@property (nonatomic, strong) UIImageView * iconView;

@property (nonatomic, strong) UILabel * myMoneyLabel;
@property (nonatomic, strong) UILabel * balanceLabel;

@property (nonatomic, strong) UIButton * rechargeBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;

@property (nonatomic, strong) UIButton * problemBtn;

@end

#define HEIGHT 56
#define MY_INSET 10

@implementation JXMyMoneyViewController

-(instancetype)init{
    if (self = [super init]) {
        self.isGotoBack   = YES;
        self.title = Localized(@"JX_MyBalance");
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//        [self createHeadAndFoot];
//        self.tableBody.scrollEnabled = YES;
        
//        NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//        self.heightHeader = -statusHeight;
//        self.heightFooter = 0;
//        self.isGotoBack = YES;
//        self.title = @"我的零钱";
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    
    self.tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    self.tableBody.alwaysBounceVertical = YES;
    
//    [self.tableHeader addSubview:self.listButton];
//
//    [self.tableBody addSubview:self.iconView];
//    [self.tableBody addSubview:self.myMoneyLabel];
//    [self.tableBody addSubview:self.balanceLabel];
//    [self.tableBody addSubview:self.rechargeBtn];
//    [self.tableBody addSubview:self.withdrawalsBtn];
//    [self.tableBody addSubview:self.problemBtn];
    
    [self setupNewWallet];
    
//    [self updateBalanceLabel];
}
- (void)backClick{
   
    [self actionQuit];

}
//12.29 修改钱包功能
- (void)setupNewWallet{
    self.tableBody.backgroundColor = HEXCOLOR(0xf8f8f8);
    
    CGFloat h = 0;
    
    NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    UIImageView *headerBgView = [UIImageView new];
    headerBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 170+statusHeight);
//    headerBgView.backgroundColor = THEMECOLOR;
    headerBgView.image = [UIImage imageNamed:@"money_header"];
    [self.tableBody addSubview:headerBgView];
    
    h += 180;
//
//    UIButton *backBtn = [UIButton buttonWithType:0];
//    [backBtn setImage:[UIImage imageNamed:@"goback"] forState:0];
//    backBtn.frame = CGRectMake(8, JX_SCREEN_TOP - 38, 31, 31);
//    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableBody addSubview:backBtn];
    
    
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 38, JX_SCREEN_WIDTH-80, 31)];
    titleL.text = @"账户余额（元）";
    titleL.textColor = [UIColor whiteColor];
    titleL.font = [UIFont systemFontOfSize:15];
//    titleL.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:titleL];
    
//    UIView *line = [UIView new];
//    line.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.5);
//    line.backgroundColor = [UIColor lightGrayColor];
//    [self.tableBody addSubview:line];
    
//    UIImageView *changeIconImageView = [UIImageView new];
//    changeIconImageView.frame = CGRectMake((JX_SCREEN_WIDTH - 80) / 2, 80+statusHeight, 80, 80);
//    changeIconImageView.image = [UIImage imageNamed:@"weixinpayyue"];
//    [self.tableBody addSubview:changeIconImageView];
    

    self.balanceLabel.frame = CGRectMake(40, CGRectGetMaxY(titleL.frame)+20, JX_SCREEN_WIDTH-80, 20);
    _balanceLabel.textAlignment = NSTextAlignmentLeft;
    _balanceLabel.textColor = [UIColor whiteColor];
    _balanceLabel.font = [UIFont systemFontOfSize:25];
    [self.tableBody addSubview:self.balanceLabel];
    
//    UIView *sepLine = [UIView new];
//    sepLine.backgroundColor = [UIColor blackColor];
    
    
    _withdrawalsBtn = [UIButton buttonWithType:0];
    [_withdrawalsBtn setTitle:@"提现 >" forState:0];
    _withdrawalsBtn.frame = CGRectMake(JX_SCREEN_WIDTH-90, titleL.bottom, 50, 30);
    [_withdrawalsBtn setTitleColor:UIColor.whiteColor forState:0];
//    _withdrawalsBtn.layer.cornerRadius = 5;
//    _withdrawalsBtn.layer.borderColor = THEMECOLOR.CGColor;
//    _withdrawalsBtn.layer.borderWidth = 1;
//    [_withdrawalsBtn setBackgroundColor: [UIColor whiteColor]];
    _withdrawalsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_withdrawalsBtn addTarget:self action:@selector(withdrawalsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:_withdrawalsBtn];
    
//    [self.tableBody addSubview:self.rechargeBtn];
//    [self.tableBody addSubview:self.withdrawalsBtn];
    
//    [self.tableBody addSubview:sepLine];
    
//    _rechargeBtn = [UIButton buttonWithType:0];
//    [_rechargeBtn setTitle:@"充值" forState:0];
//    _rechargeBtn.frame = CGRectMake(15, headerBgView.bottom+13, JX_SCREEN_WIDTH-30, 44);
//    [_rechargeBtn setTitleColor:[UIColor whiteColor] forState:0];
//    _rechargeBtn.layer.cornerRadius = 5;
//    [_rechargeBtn setBackgroundColor: THEMECOLOR];
//    [_rechargeBtn addTarget:self action:@selector(rechargeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableBody addSubview:_rechargeBtn];
    
    
//    _withdrawalsBtn = [UIButton buttonWithType:0];
//    [_withdrawalsBtn setTitle:@"提现" forState:0];
//    _withdrawalsBtn.frame = CGRectMake(15, _rechargeBtn.bottom+15, JX_SCREEN_WIDTH-30, 44);
//    [_withdrawalsBtn setTitleColor:THEMECOLOR forState:0];
//    _withdrawalsBtn.layer.cornerRadius = 5;
//    _withdrawalsBtn.layer.borderColor = THEMECOLOR.CGColor;
//    _withdrawalsBtn.layer.borderWidth = 1;
//    [_withdrawalsBtn setBackgroundColor: [UIColor whiteColor]];
//    [_withdrawalsBtn addTarget:self action:@selector(withdrawalsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableBody addSubview:_withdrawalsBtn];
    
//    _rechargeBtn.frame = CGRectMake(0, CGRectGetMaxY(headerBgView.frame), JX_SCREEN_WIDTH / 2, 50);
//    _withdrawalsBtn.frame = CGRectMake(JX_SCREEN_WIDTH / 2, CGRectGetMaxY(headerBgView.frame), JX_SCREEN_WIDTH / 2, 50);
    
//    sepLine.frame = CGRectMake(JX_SCREEN_WIDTH / 2, self.rechargeBtn.frame.origin.y + 5, 1, self.rechargeBtn.frame.size.height - 10);

    
    h += 10;
//    #pragma mark - 莫杭修改
//    JXImageView *rechargeView = [self createButton:@"充值" drawTop:YES drawBottom:NO icon:@"money_chongzhi" click:@selector(rechargeBtnAction:)];
//    rechargeView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
//    [self.tableBody addSubview:rechargeView];
//
//    h +=  HEIGHT;
    

    
//    JXImageView *redPackageImageView = [self createButton:@"红包明细" drawTop:YES drawBottom:NO icon:@"change_icon_bill" click:@selector(billAction)];
//    redPackageImageView.frame = CGRectMake(0, CGRectGetMaxY(_withdrawalsBtn.frame) + 10, JX_SCREEN_WIDTH, 56);
//    [self.tableBody addSubview:redPackageImageView];
//
//    h +=  HEIGHT;
    
//    JXImageView *redPacketImageView = [self createButton:@"红包明细" drawTop:YES drawBottom:YES icon:@"money_honhbaomingxi" click:@selector(billAction)];
//    redPacketImageView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
//    [self.tableBody addSubview:redPacketImageView];
//
//    h += HEIGHT;
    
    //    UIButton *bill = [self createViewWithFrame:CGRectMake(0, CGRectGetMaxY(_withdrawalsBtn.frame) + 10, JX_SCREEN_WIDTH, 56) title:@"账单" icon:@"" index:0 showLine:YES click:@selector(billAction)];
    
    JXImageView *billImageView = [self createButton:@"零钱明细" drawTop:YES drawBottom:NO icon:@"money_lingqianmingxi" click:@selector(billAction)];
    billImageView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
    [self.tableBody addSubview:billImageView];
    
    h +=  HEIGHT;
    
    JXImageView *myBankCard = [self createButton:@"我的卡包" drawTop:YES drawBottom:NO icon:@"money_kabao" click:@selector(myPayAndBankCard)];
    myBankCard.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
    [self.tableBody addSubview:myBankCard];
    
    h += HEIGHT;

       JXImageView *forgetPayPassword = [self createButton:@"支付管理" drawTop:YES drawBottom:YES icon:@"money_zhifufangshi" click:@selector(payPasswordManageAction)];
       forgetPayPassword.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, 56);
       [self.tableBody addSubview:forgetPayPassword];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [g_server getUserMoenyToView:self];
}

- (void)billAction{
    
    JXRecordCodeVC * recordVC = [[JXRecordCodeVC alloc]init];
    [g_navigation pushViewController:recordVC animated:YES];
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

- (void)myPayAndBankCard {
    
    JXAddBankCardAndAlipayVC * addBankCardVC = [[JXAddBankCardAndAlipayVC alloc] init];
    [g_navigation pushViewController:addBankCardVC animated:YES];
}

-(void)dealloc{
    [g_notify removeObserver:self];
}


-(UIButton *)listButton{
    if(!_listButton){
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _listButton.frame = CGRectMake(JX_SCREEN_WIDTH-24-15, JX_SCREEN_TOP - 35, 24, 24);
//        [_listButton setTitle:Localized(@"JXMoney_list") forState:UIControlStateNormal];
//        [_listButton setTitle:Localized(@"JXMoney_list") forState:UIControlStateHighlighted];
//        _listButton.titleLabel.font = g_factory.font14;
        [_listButton setImage:THESIMPLESTYLE ? [UIImage imageNamed:@"money_menu_black"] : [UIImage imageNamed:@"money_menu"] forState:UIControlStateNormal];
        _listButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listButton;
}


-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.frame = CGRectMake(0, 65, 90, 90);
        _iconView.center = CGPointMake(JX_SCREEN_WIDTH/2, _iconView.center.y);
        _iconView.image = [UIImage imageNamed:@"weixinpayyue"];
        
    }
    return _iconView;
}

-(UILabel *)myMoneyLabel{
    if (!_myMoneyLabel) {
        _myMoneyLabel = [UIFactory createLabelWith:CGRectZero text:Localized(@"JXMoney_myPocket") font:g_factory.font14 textColor:[UIColor blackColor] backgroundColor:nil];
        _myMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _myMoneyLabel.frame = CGRectMake(0, CGRectGetMaxY(_iconView.frame)+20, JX_SCREEN_WIDTH, 20);
        _myMoneyLabel.center = CGPointMake(_iconView.center.x, _myMoneyLabel.center.y);
    }
    return _myMoneyLabel;
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font28 textColor:[UIColor blackColor] backgroundColor:nil];
        _balanceLabel.textAlignment = NSTextAlignmentCenter;
        _balanceLabel.frame = CGRectMake(0, CGRectGetMaxY(_myMoneyLabel.frame)+5, JX_SCREEN_WIDTH, 30);
        _balanceLabel.center = CGPointMake(_iconView.center.x, _balanceLabel.center.y);
    }
    return _balanceLabel;
}

//-(UIButton *)rechargeBtn{
//    if (!_rechargeBtn) {
//        _rechargeBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXLiveVC_Recharge") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(rechargeBtnAction:) target:self];
//        _rechargeBtn.frame = CGRectMake(15, CGRectGetMaxY(_balanceLabel.frame) + 40, JX_SCREEN_WIDTH-15*2, 50);
//        [_rechargeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//
//
////        UIImage *rechareImage = [[UIImage imageNamed:@"wallet_icon_recharge"] imageByScalingToSize:CGSizeMake(25, 25)];
//        UIImage *rechareImage = [UIImage imageNamed:@"wallet_icon_recharge"];
//
//        [_rechargeBtn setImage: rechareImage forState:UIControlStateNormal];
//        _rechargeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//        [_rechargeBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
////        _rechargeBtn .layer.cornerRadius = 5;
//        _rechargeBtn.clipsToBounds = YES;
//    }
//    return _rechargeBtn;
//}
//
//-(UIButton *)withdrawalsBtn{
//    if (!_withdrawalsBtn) {
//        _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_withdrawals") titleFont:g_factory.font16 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
//        _withdrawalsBtn.frame = CGRectMake(15, CGRectGetMaxY(_rechargeBtn.frame)+20, CGRectGetWidth(_rechargeBtn.frame), CGRectGetHeight(_rechargeBtn.frame));
//        [_withdrawalsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_withdrawalsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
//        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
////        UIImage *rechareImage = [[UIImage imageNamed:@"wallet_icon_withdraw"] imageByScalingToSize:CGSizeMake(25, 25)];
//        UIImage *rechareImage = [UIImage imageNamed:@"wallet_icon_withdraw"];
//
//        [_withdrawalsBtn setImage:rechareImage forState:UIControlStateNormal];
//        _withdrawalsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
////        _withdrawalsBtn .layer.cornerRadius = 5;
//        _withdrawalsBtn.clipsToBounds = YES;
//    }
//    return _withdrawalsBtn;
//}

-(UIButton *)problemBtn{
    if (!_problemBtn) {
        _problemBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_FAQ") titleFont:g_factory.font14 titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(problemBtnAction) target:self];
        CGFloat drawWidth = [_problemBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_problemBtn.titleLabel.font}].width;
        _problemBtn.frame = CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-25-5, drawWidth, 25);
        _problemBtn.center = CGPointMake(JX_SCREEN_WIDTH/2, _problemBtn.center.y);
    }
    return _problemBtn;
}


-(void)updateBalanceLabel{
    NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
    self.balanceLabel.text = moneyStr;
//    CGFloat Width = [self.balanceLabel.text sizeWithAttributes:@{NSFontAttributeName:self.balanceLabel.font}].width;
//    CGRect frame = self.balanceLabel.frame;
//    frame.size.width = Width;
//    self.balanceLabel.frame = frame;
//    self.balanceLabel.center = CGPointMake(self.iconView.center.x, self.balanceLabel.center.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)createViewWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)icon index:(CGFloat)index showLine:(BOOL)isShow click:(SEL)click{
    
    UIButton *view = [[UIButton alloc] init];
    [view setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [view setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xF6F5FA)] forState:UIControlStateHighlighted];
    view.frame = frame;
    view.tag = index;
    [self.tableBody addSubview:view];

    int imgH = 40.5;
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.frame = CGRectMake((view.frame.size.width-imgH)/2, (view.frame.size.height-imgH-15-3)/2, imgH, imgH);
    imgV.image = [UIImage imageNamed:icon];
    [view addSubview:imgV];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame)+3, view.frame.size.width, 15);
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = SYSFONT(15);
    label.textColor = HEXCOLOR(0x323232);
    [view addSubview:label];
  
    if (isShow) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width-.5, (view.frame.size.height-24)/2, .5, 24)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [view addSubview:line];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:click];
    [view addGestureRecognizer:tap];
    
    return view;
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

#pragma mark Action

-(void)listButtonAction{
    _listButton.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    JXMoneyMenuViewController *monVC = [[JXMoneyMenuViewController alloc] init];
    [g_navigation pushViewController:monVC animated:YES];
//    JXRecordCodeVC * recordVC = [[JXRecordCodeVC alloc]init];
////    [g_window addSubview:recordVC.view];
//    [g_navigation pushViewController:recordVC animated:YES];
}

- (void)payPasswordManageAction{
    
    [g_navigation pushViewController:[JXPasswordManageViewController new] animated:YES];
}

-(void)rechargeBtnAction:(UIButton *)button{
    _rechargeBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    JXRechargeViewController * rechargeVC = [[JXRechargeViewController alloc] init];
    
//    [g_window addSubview:rechargeVC.view];
    [g_navigation pushViewController:rechargeVC animated:YES];
}
-(void)withdrawalsBtnAction:(UIButton *)button{
    _withdrawalsBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
    JXCashWithDrawViewController * cashWithVC = [[JXCashWithDrawViewController alloc] init];
//    [g_window addSubview:cashWithVC.view];
    [g_navigation pushViewController:cashWithVC animated:YES];
}

-(void)problemBtnAction{
    _problemBtn.enabled = NO;
    [self performSelector:@selector(delayButtonReset) withObject:nil afterDelay:0.5];
    
}

-(void)delayButtonReset{
    _rechargeBtn.enabled = YES;
    _withdrawalsBtn.enabled = YES;
    _problemBtn.enabled = YES;
    _listButton.enabled = YES;
}

-(void)doRefresh:(NSNotification *)notifacation{
    _balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
}
//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];

    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        _balanceLabel.text = moneyStr;
    }
}

@end
