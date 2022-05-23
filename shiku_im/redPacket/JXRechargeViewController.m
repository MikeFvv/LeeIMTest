//
//  JXRechargeViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/30.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXRechargeViewController.h"
#import "JXRechargeCell.h"
#import "UIImage+Color.h"
#import "RITLWebViewController.h"
#import "UIImage-Extensions.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl.h"
#import "WXApi.h"
@interface JXRechargeMoneyTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *rechargeBgView;
@property (nonatomic, strong) UILabel *rechargeLabel;
@property (nonatomic, strong) UILabel *rmbLabel;
@property (nonatomic, strong) UITextField *inputMoneyTextField;
@property (nonatomic, strong) NSArray *moneyArray;
@property (nonatomic, copy)  void (^inputMoneyChanged)(NSString *money);

@property (nonatomic, strong) UIButton *previousSelectButton;



@end

@implementation JXRechargeMoneyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _moneyArray = @[@"50", @"100",@"200",@"500",@"1000",@"2000"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    
    [self.contentView addSubview:self.rechargeBgView];
    
    [self.rechargeBgView addSubview:self.rechargeLabel];
    [self.rechargeBgView addSubview:self.rmbLabel];
    [self.rechargeBgView addSubview:self.inputMoneyTextField];
    
    [self setupChargeButtonViews];
}

- (void)setupChargeButtonViews{
    
    
    CGFloat margin = 20;
    CGFloat buttonWidth = (JX_SCREEN_WIDTH - margin * 4) / 3;
    CGFloat buttonTop = CGRectGetMaxY(self.inputMoneyTextField.frame) + 50;
    CGFloat buttonHeight = 50;
    
    for (NSInteger i = 0; i < _moneyArray.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_moneyArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.borderWidth = 1;
        button.titleLabel.font = [UIFont systemFontOfSize:20];
        
        CGFloat originX = i % 3 * (margin + buttonWidth) + margin;
        CGFloat originY = buttonTop + i / 3 *  (buttonHeight + margin) ;
        
        button.frame = CGRectMake(originX, originY , buttonWidth, buttonHeight);
        button.tag = i + 100;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
    }
}

- (void)buttonAction: (UIButton *)sender {
    
    
    
    NSString *moneyStr = _moneyArray[sender.tag - 100];
    _inputMoneyTextField.text = moneyStr;
    self.inputMoneyChanged(moneyStr);
    
    _previousSelectButton.selected = NO;
    sender.selected = YES;
    _previousSelectButton = sender;
}

- (UIView *)rechargeBgView {
    
    if (!_rechargeBgView) {
        _rechargeBgView = [UIView new];
        _rechargeBgView.layer.cornerRadius = 10;
        _rechargeBgView.backgroundColor = [UIColor whiteColor];
        _rechargeBgView.layer.masksToBounds = YES;
        
        _rechargeBgView.frame = CGRectMake(10, 10, JX_SCREEN_WIDTH - 20, 120);
    }
    return _rechargeBgView;
}

- (UILabel *)rechargeLabel{
    
    if (!_rechargeLabel) {
        
        _rechargeLabel = [UILabel new];
        _rechargeLabel.text = @"充值金额";
        _rechargeLabel.font = [UIFont systemFontOfSize:15];
        _rechargeLabel.textColor = [UIColor lightGrayColor];
        _rechargeLabel.frame = CGRectMake(20, 10, 100, 20);
    }
    return _rechargeLabel;
}

- (UILabel *)rmbLabel{
    
    if (!_rmbLabel) {
        
        _rmbLabel = [UILabel new];
        _rmbLabel.text = @"￥";
        _rmbLabel.font = [UIFont systemFontOfSize:15];
        _rmbLabel.textColor = [UIColor blackColor];
        _rmbLabel.frame = CGRectMake(20, CGRectGetMaxY(self.rechargeLabel.frame) + 20, 100, 20);
    }
    return _rmbLabel;
}

- (UITextField *)inputMoneyTextField {
    
    if (!_inputMoneyTextField) {
        
        _inputMoneyTextField = [UITextField new];
        _inputMoneyTextField.placeholder = @"请输入充值金额";
        _inputMoneyTextField.font = [UIFont boldSystemFontOfSize:30];
        _inputMoneyTextField.backgroundColor = [UIColor whiteColor];
        _inputMoneyTextField.tintColor = THEMECOLOR;
//        _inputMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
        _inputMoneyTextField.frame = CGRectMake(20, CGRectGetMaxY(self.rmbLabel.frame) + 20, 280, 32);
        [_inputMoneyTextField addTarget:self action:@selector(inputMoneyTextFiledChanged) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _inputMoneyTextField;
}

- (void)inputMoneyTextFiledChanged{
    
    self.inputMoneyChanged(_inputMoneyTextField.text);
}



@end

@interface JXSelectButtonView : UIImageView

@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, assign) NSInteger type;

@end

@implementation JXSelectButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type {
    
    if ([super initWithFrame:frame]) {
        
        self.type = type;
        
        self.userInteractionEnabled = YES;
        [self addSubview:self.selectButton];
        [self addSubview:self.imageButton];
    }
    return self;
}

- (UIButton *)selectButton{
    
    if (!_selectButton) {
        
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *image = [[UIImage imageNamed:@"select_button"] imageByScalingToSize:CGSizeMake(30, 30)];
        UIImage *selectImage = [[UIImage imageNamed:@"selected_button"] imageByScalingToSize:CGSizeMake(30, 30)];

        [_selectButton setImage:image forState:UIControlStateNormal];
        [_selectButton setImage:selectImage forState:UIControlStateSelected];
        _selectButton.frame = CGRectMake(10, (self.frame.size.height - 40) / 2, 40, 40);

        
        if (_type == 1) {
            _selectButton.selected = true;
        }
    }
    return _selectButton;
}

- (UIButton *)imageButton{
    
    if (!_imageButton) {
        
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _imageButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _imageButton.frame = CGRectMake(CGRectGetMaxX(self.selectButton.frame), (self.frame.size.height - 40) / 2, 100, 40);
        _imageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _imageButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        if (_type == 1) {
            
            UIImage *image = [[UIImage imageNamed:@"payment_zhifubao111"] imageByScalingToSize:CGSizeMake(40, 40)];
//            UIImage *image = [UIImage imageNamed:@"payment_zhifubao111"];

            [_imageButton setImage:image forState:UIControlStateNormal];
            [_imageButton setTitle:@"支付宝" forState:UIControlStateNormal];
        }
        else {
            
            UIImage *image = [[UIImage imageNamed:@"wechat001_icon"] imageByScalingToSize:CGSizeMake(40, 40)];
            [_imageButton setImage:image forState:UIControlStateNormal];
            [_imageButton setTitle:@"微信" forState:UIControlStateNormal];
        }
        
    }
    return _imageButton;
}

@end

@interface JXRechargeViewController ()<UIAlertViewDelegate,WXApiDelegate>
@property (nonatomic, assign) NSInteger checkIndex;
@property (atomic, assign) NSInteger payType;


//@property (nonatomic, strong) NSArray * rechargeArray;
@property (nonatomic, strong) NSArray * rechargeMoneyArray;


@property (nonatomic, strong) UILabel * totalMoney;
@property (nonatomic, strong) UIButton * wxPayBtn;
@property (nonatomic, strong) UIButton * aliPayBtn;

@property (nonatomic, strong) JXSelectButtonView *alipayButton;
@property (nonatomic, strong) JXSelectButtonView *wechatButton;

@property (nonatomic, copy) NSString *inputMoney;


@end

static NSString * JXRechargeCellID = @"JXRechargeCellID";

@implementation JXRechargeViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXLiveVC_Recharge");
        [self makeData];
        _checkIndex = -1;
        
        [g_notify addObserver:self selector:@selector(receiveWXPayFinishNotification:) name:kWxPayFinishNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.isShowHeaderPull = NO;
    self.isShowFooterPull = NO;
    _table.backgroundColor = HEXCOLOR(0xefeff4);
//    [_table registerClass:[JXRechargeCell class] forCellReuseIdentifier:JXRechargeCellID];
    
    
    [_table registerClass:[JXRechargeMoneyTableViewCell class] forCellReuseIdentifier:@"JXRechargeMoneyTableViewCell"];
    _table.showsVerticalScrollIndicator = NO;
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UITapGestureRecognizer *Tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [_table addGestureRecognizer:Tap];
}
- (void)tapClick{
    
    [self.view endEditing:YES];
    [self.tableView endEditing:YES];
}
-(void)dealloc{
    [g_notify removeObserver:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _rechargeMoneyArray.count;
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 300 + 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    JXRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:JXRechargeCellID forIndexPath:indexPath];
//    NSString * money = [NSString stringWithFormat:@"%@%@",_rechargeMoneyArray[indexPath.row],Localized(@"JX_ChinaMoney")];
//    cell.textLabel.text = money;
//    if(_checkIndex == indexPath.row){
//        cell.checkButton.selected = YES;
//    }
    
     JXRechargeMoneyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXRechargeMoneyTableViewCell" forIndexPath:indexPath];
    cell.inputMoneyChanged = ^(NSString *money) {
        self.inputMoney = money;
    };
   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    _checkIndex = indexPath.row;
//    NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[indexPath.row]];
//    [self setTotalMoneyText:money];
//    NSArray * cellArray = [tableView visibleCells];
//    for (JXRechargeCell * cell in cellArray) {
//        cell.checkButton.selected = NO;
//    }
//
//    JXRechargeCell * selCell = [tableView cellForRowAtIndexPath:indexPath];
//    selCell.checkButton.selected = YES;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 300;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * paySelView = [[UIView alloc] init];
    
    paySelView.backgroundColor = HEXCOLOR(0xefeff4);
//    UILabel * payStyleLabel = [UIFactory createLabelWith:CGRectMake(20, 0, JX_SCREEN_WIDTH-20*2, 40) text:Localized(@"JXMoney_choosePayType") font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    [paySelView addSubview:payStyleLabel];
    
    UIView * whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
//    whiteView.frame = CGRectMake(0, CGRectGetMaxY(payStyleLabel.frame), JX_SCREEN_WIDTH, 300 -CGRectGetMaxY(payStyleLabel.frame));
    whiteView.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 300 -40);
    [paySelView addSubview:whiteView];

//    UILabel * totalTitle = [UIFactory createLabelWith:CGRectZero text:nil font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    NSString * totalStr = Localized(@"JXMoney_total");
//    CGFloat totalWidth = [totalStr sizeWithAttributes:@{NSFontAttributeName:totalTitle.font}].width;
//    totalTitle.frame = CGRectMake(20, 20, totalWidth+5, 18);
//    totalTitle.text = totalStr;
//    [whiteView addSubview:totalTitle];
//
//
//    _totalMoney = [UIFactory createLabelWith:CGRectZero text:nil font:g_factory.font20 textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
//    NSString * totalMoneyStr = @"¥--";
//    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
//    _totalMoney.frame = CGRectMake(CGRectGetMaxX(totalTitle.frame), 20, moneyWidth+5, 18);
//    _totalMoney.text = totalMoneyStr;
//    _totalMoney.textColor = [UIColor redColor];
//    [whiteView addSubview:_totalMoney];
    
//    _wxPayBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_wxPay") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(wxPayBtnAction:) target:self];
//    _wxPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_totalMoney.frame)+20, JX_SCREEN_WIDTH-20*2, 40);
//    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
//    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//    _wxPayBtn.layer.cornerRadius = 5;
//    _wxPayBtn.clipsToBounds = YES;
//    [whiteView addSubview:_wxPayBtn];
    
//    _alipayButton = [[JXSelectButtonView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH / 2 - 170, 30, 150, 50) type:1];
//    _alipayButton.selectButton.selected = YES;
//    [_alipayButton.imageButton addTarget:self action:@selector(aliPayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [whiteView addSubview:_alipayButton];
    
//    //设置为支付宝
    self.payType = 1;
//    
//    _wechatButton = [[JXSelectButtonView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH / 2 + 20, 30, 150, 50) type:2];
//    [_wechatButton.imageButton addTarget:self action:@selector(wxPayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [whiteView addSubview:_wechatButton];
    
    UIButton *confirmButton = [UIFactory createButtonWithRect:CGRectZero title:@"确认充值" titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(confirmPayButtonAction) target:self];
    confirmButton.frame = CGRectMake(20, CGRectGetMaxY(_wechatButton.frame) + 30, JX_SCREEN_WIDTH - 40, 44);
    [confirmButton setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateDisabled];
    confirmButton.layer.cornerRadius = 22;
    confirmButton.clipsToBounds = YES;
    [whiteView addSubview:confirmButton];
    

//    _aliPayBtn = [UIFactory createButtonWithRect:CGRectZero title:Localized(@"JXMoney_aliPay") titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(aliPayBtnAction:) target:self];
//    _aliPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_wxPayBtn.frame)+15, JX_SCREEN_WIDTH-20*2, 40);
//    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
//    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//    _aliPayBtn.layer.cornerRadius = 5;
//    _aliPayBtn.clipsToBounds = YES;
//    [whiteView addSubview:_aliPayBtn];
    
    
    return paySelView;
}

- (void)confirmPayButtonAction{
    
    
    NSLog(@"执行确认充值");
    
    //判断如果小于10，需提示错误
    if ([self.inputMoney floatValue] < 1) {

        [g_server showMsg:@"充值金额需大于1元"];
        return;
    }
    
//    [UPPaymentControl defaultControl]
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
////    //设置超时时间
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 30.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain",@"charset=UTF-8",nil];
//    NSLog(@"MY_USER_ID == %@",MY_USER_ID);
//    NSString *str = MY_USER_ID;
//
//
//    NSLog(@"str_ MY_USER_ID == %@",str);
//    NSLog(@"self.inputMoney == %@",self.inputMoney);
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:self.inputMoney forKey:@"amount"];
//    [dic setValue:@([str integerValue]) forKey:@"userId"];
//    @{@"amount":self.inputMoney,@"userId":@([str integerValue])}
    
    
//    NSLog(@"dic == %@",dic);
//    [manager POST:[NSString stringWithFormat:XL_API_URL@"unionpay/consume?&amount=%@&userId=%@",self.inputMoney,str] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//        NSLog(@"支付返回值  == %@",obj);
//        [[UPPaymentControl defaultControl] startPay:obj[@"data"][@"tn"] fromScheme:@"" mode:@"00" viewController:self];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
    
//    [g_server getXLPayMoney:self.inputMoney UserId:str secret:@"" time:nil toView:self];
    
    
    NSString *thirdPayType = @"alipay";
//    if (self.payType == 2) {
//        thirdPayType = @"wxpay";
//    }
    
    
    
//    [g_server getThirdPayWithPayType:thirdPayType money: self.inputMoney toView:self];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"请选择支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *weChat = [UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [g_server getSign:self.inputMoney payType:2 toView:self];
    }];
    UIAlertAction *aLi = [UIAlertAction actionWithTitle:@"支付宝支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [g_server getSign:self.inputMoney payType:1 toView:self];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionSheet addAction:weChat];
    [actionSheet addAction:aLi];
    [actionSheet addAction:cancel];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)setTotalMoneyText:(NSString *)money{
    
    NSString * totalMoneyStr = [NSString stringWithFormat:@"¥%@",money];
    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
    CGRect frame = _totalMoney.frame;
    frame.size.width = moneyWidth;
    _totalMoney.frame = frame;
    _totalMoney.text = totalMoneyStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)makeData{
//    self.rechargeArray = @[@"10元",
//                           @"50元",
//                           @"100元",
//                           @"500元",
//                           @"1000元",
//                           @"5000元",
//                           @"10000元"];
    
    self.rechargeMoneyArray = @[@0.01,
                                @1,
                                @10,
                                @50,
                                @100,
                                @500,
                                @1000,
                                @5000,
                                @10000];
}


#pragma mark Action

-(void)wxPayBtnAction:(UIButton *)button{
    
    _alipayButton.selectButton.selected = NO;
    _wechatButton.selectButton.selected = YES;
    _payType = 2;
    
    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
        _payType = 2;
        [g_server getSign:money payType:2 toView:self];
    }
}

-(void)aliPayBtnAction:(UIButton *)button{
    
    _alipayButton.selectButton.selected = YES;
    _wechatButton.selectButton.selected = NO;
    _payType = 1;
    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
        _payType = 1;
        [g_server getSign:money payType:1 toView:self];
    }
}

-(void)tuningWxWith:(NSDictionary *)dict{
    [WXApi registerApp:[dict objectForKey:@"appId"] universalLink:@""];
    
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = [dict objectForKey:@"partnerId"];
    req.prepayId = [dict objectForKey:@"prepayId"];
    req.nonceStr = [dict objectForKey:@"nonceStr"];
    req.timeStamp = [[dict objectForKey:@"timeStamp"] intValue];
    req.package = [dict objectForKey:@"package"];
    req.sign = [dict objectForKey:@"sign"];
    
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
//    int a = 1;
}
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess:
                [g_App showAlert:Localized(@"JXMoney_PaySuccess") delegate:self tag:1001 onlyConfirm:YES];
                if (self.rechargeDelegate && [self.rechargeDelegate respondsToSelector:@selector(rechargeSuccessed)]) {
                    [self.rechargeDelegate performSelector:@selector(rechargeSuccessed)];
                }
                if (_isQuitAfterSuccess) {
                    [self actionQuit];
                }
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"支付失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
            }
        }
    }else {
    }
}

- (void)onReq:(BaseReq *)req {

}

- (void)tuningAlipayWithOrder:(NSString *)signedString {
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"zhiliaoapp";
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }

}

-(void)receiveWXPayFinishNotification:(NSNotification *)notifi{
    PayResp *resp = notifi.object;
    switch (resp.errCode) {
        case WXSuccess:{
            [g_App showAlert:Localized(@"JXMoney_PaySuccess") delegate:self tag:1001 onlyConfirm:YES];
            if (self.rechargeDelegate && [self.rechargeDelegate respondsToSelector:@selector(rechargeSuccessed)]) {
                [self.rechargeDelegate performSelector:@selector(rechargeSuccessed)];
            }
            if (_isQuitAfterSuccess) {
                [self actionQuit];
            }
            break;
        }
        case WXErrCodeUserCancel:{
            //取消了支付
            break;
        }
        default:{
            //支付错误
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"支付失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_server getUserMoenyToView:self];
        });
    }
}


- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    
    [_wait stop];
    if ([aDownload.action isEqualToString:@"unionpay/consume"]) {
//        if ([[dict objectForKey:@"package"] isEqualToString:@"Sign=WXPay"]) {
//            [self tuningWxWith:dict];
//        }else {
//            [self tuningAlipayWithOrder:[dict objectForKey:@"orderInfo"]];
//        }
    }else if ([aDownload.action isEqualToString:act_getSign]) {
        if ([[dict objectForKey:@"package"] isEqualToString:@"Sign=WXPay"]) {
            [self tuningWxWith:dict];
        }else {
            [self tuningAlipayWithOrder:[dict objectForKey:@"orderInfo"]];
        }
    }else if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        [self actionQuit];
    }
    
    if ([aDownload.action isEqualToString:act_GetThirdPayAddress]) {
        
        NSString *responseStr = aDownload.responseData;
        
        NSData *jsonData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        
        RITLWebViewController *webVC = [[RITLWebViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        
        webVC.url = [self URLEncodedString:dic[@"data"]];
        webVC.useLeftCloseItem = YES;
        webVC.leftCloseImage = [UIImage imageNamed:@"talk_close"];
        webVC.leftCloseButtonTap = ^(RITLWebViewController * _Nonnull viewController, UIBarButtonItem * _Nonnull item) {
            
//            [viewController.navigationController popViewControllerAnimated:true];
            
            [g_navigation popToViewController:[JXRechargeViewController class] animated:YES];

        };
        [g_navigation pushViewController:nav animated:true];
    }
    
  
}
- (NSString *)URLEncodedString:(NSString *)urlStr
{
    NSString *unencodedString = urlStr;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
      
    return encodedString;
}
- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    //    if ([aDownload.action isEqualToString:]) {
    //        return hide_error
    //    }
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    //    if ([aDownload.action isEqualToString:]) {
    //        [self refreshAfterConnectError];
    //    }
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

@end



