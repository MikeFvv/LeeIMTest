//
//  JXCashWithDrawViewController.m
//  shiku_im
//
//  Created by 1 on 17/10/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCashWithDrawViewController.h"
#import "UIImage+Color.h"
#import "JXVerifyPayVC.h"
#import "JXPayPasswordVC.h"
#import "JXPickerView.h"
#import "YZBottomSelectView.h"
#import "JXMyMoneyViewController.h"
#import "UIImage-Extensions.h"
#import "JXAddBankCardAndAlipayVC.h"

#define drawMarginX 25
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 60

#define HEIGHT   56

@interface JXWithDrawConfirmView : UIView

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *bankNameButton;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UILabel *withDrawLabel;
@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, copy)   void (^confirmBlock)();


+ (void)showConfirmViewWithDict:(NSDictionary *)dict confirmBlock:(void(^)())confirmBlock;

@end

@implementation JXWithDrawConfirmView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        UIView *bgView = [UIView new];
        bgView.frame = CGRectMake(50, (JX_SCREEN_HEIGHT - 250) / 2, JX_SCREEN_WIDTH - 100, 250);
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 6;
        [self addSubview:bgView];
        
        CGFloat h = 10;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(0, h, bgView.frame.size.width, 20);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"提现到";
        [bgView addSubview:titleLabel];
        
        h += 40;
        
        _bankNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_confirmButton setTitle:@"中国建设银行" forState:UIControlStateNormal];
        _bankNameButton.frame = CGRectMake(20, h, bgView.frame.size.width - 40, 20);
        [_bankNameButton setTitleColor:[UIColor blackColor]
                             forState:UIControlStateNormal];
        _bankNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [bgView addSubview:_bankNameButton];
        
        h += 40;
        _amountLabel = [UILabel new];
        _amountLabel.frame = CGRectMake(20, h, bgView.frame.size.width - 40, 20);
        _amountLabel.text = @"￥100";
        _amountLabel.textAlignment = NSTextAlignmentCenter;
        _amountLabel.font = [UIFont boldSystemFontOfSize:18];
        [bgView addSubview:_amountLabel];
        
        h += 40;
        _withDrawLabel = [UILabel new];
        _withDrawLabel.frame = CGRectMake(20, h, bgView.frame.size.width - 40, 20);
        _withDrawLabel.text = @"提现金额: ￥100";
        _withDrawLabel.textAlignment = NSTextAlignmentLeft;
        _withDrawLabel.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:_withDrawLabel];
        
        h += 30;
        _serviceLabel = [UILabel new];
        _serviceLabel.frame = CGRectMake(20, h, bgView.frame.size.width - 40, 20);
        _serviceLabel.text = @"手续费: ￥100";
        _serviceLabel.textAlignment = NSTextAlignmentLeft;
        _serviceLabel.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:_serviceLabel];
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(0, bgView.frame.size.height - 40, bgView.frame.size.width / 2, 40);
        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [bgView addSubview:cancelButton];
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.frame = CGRectMake(bgView.frame.size.width / 2, bgView.frame.size.height - 40, bgView.frame.size.width / 2, 40);
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        //        [_confirmButton addTarget:self action:self.didSelect forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.custom_acceptEventInterval = 0.2;
        [bgView addSubview:_confirmButton];
        
        UIView *horizontalLine = [UIView new];
        horizontalLine.backgroundColor = [UIColor lightGrayColor];
        horizontalLine.frame = CGRectMake(0, _confirmButton.frame.origin.y, bgView.frame.size.width, 1);
        [bgView addSubview:horizontalLine];
        
        UIView *verticalLine = [UIView new];
        verticalLine.backgroundColor = [UIColor lightGrayColor];
        verticalLine.frame = CGRectMake(bgView.frame.size.width / 2, _confirmButton.frame.origin.y + 4, 1, _confirmButton.frame.size.height - 8);
        [bgView addSubview:verticalLine];
    }
    return self;
}

+ (void)showConfirmViewWithDict:(NSDictionary *)dict confirmBlock:(void (^)())confirmBlock{
    
    JXWithDrawConfirmView *confirmView = [[JXWithDrawConfirmView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    confirmView.confirmBlock = confirmBlock;
    
    confirmView.withDrawLabel.text = dict[@"withDrawMoney"];
    confirmView.serviceLabel.text = dict[@"serviceMoney"];
    confirmView.amountLabel.text = dict[@"amount"];
    
    NSDictionary *bankDict = dict[@"bankResult"];
    NSString *bankStr = [NSString stringWithFormat:@"%@   %@", bankDict[@"bankBrandName"], bankDict[@"cardNo"]];
    [confirmView.bankNameButton setTitle:bankStr forState:UIControlStateNormal];
    
    NSDictionary *nameDict = @{@"100" : @"payment_zhifubao",
    @"101" : @"ic_card_boc",
    @"102" : @"ic_card_ccb",
    @"103" : @"ic_card_icbc",
    @"104" : @"ic_card_abc",
    @"105" : @"ic_card_comm",
    @"106" : @"ic_card_psbc",
//                               @"107" : @"北京银行_爱给网_aigei_com",
//                               @"108" : @"渤海银行_爱给网_aigei_com",
//                               @"109" : @"广发银行_爱给网_aigei_com",
//                               @"110" : @"恒丰银行_爱给网_aigei_com",
//                               @"111" : @"华夏银行_爱给网_aigei_com",
//                               @"112" : @"上海银行_爱给网_aigei_com",
//                               @"113" : @"温州银行_爱给网_aigei_com",
//                               @"114" : @"兴业银行_爱给网_aigei_com",
//                               @"115" : @"招商银行_爱给网_aigei_com",
//                               @"116" : @"浙商银行_爱给网_aigei_com",
//                               @"117" : @"中国光大银行_爱给网_aigei_com",
//                               @"118" : @"中国民生银行_爱给网_aigei_com",
//                               @"119" : @"中信银行_爱给网_aigei_com"
    };
    
    NSString *bankBrandId = [NSString stringWithFormat:@"%@", bankDict[@"bankBrandId"]];
    NSString *imageNmaed = nameDict[bankBrandId];
    
    UIImage *image = [UIImage imageNamed:imageNmaed];
    image = [image imageByScalingToSize:CGSizeMake(20, 20)];
    [confirmView.bankNameButton setImage:image forState:UIControlStateNormal];
    
//    confirmView.bankNameButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    confirmView.bankNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    confirmView.bankNameButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    confirmView.bankNameButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [g_window addSubview:confirmView];
}

- (void)cancelButtonAction{
    
    [self removeFromSuperview];
}

- (void)confirmButtonAction{
    
    
    self.confirmBlock();
    [self removeFromSuperview];

}

@end

@interface JXCashWithDrawViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton * helpButton;

@property (nonatomic, strong) UIControl * hideControl;
@property (nonatomic, strong) UIControl * bgView;
@property (nonatomic, strong) UIView * targetView;
@property (nonatomic, strong) UIView * inputView;
@property (nonatomic, strong) UIView * balanceView;

@property (nonatomic, strong) UIButton * cardButton;
@property (nonatomic, strong) UITextField * countTextField;

@property (nonatomic, strong) UILabel * balanceLabel;
@property (nonatomic, strong) UIButton * drawAllBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;
@property (nonatomic, strong) UIButton * aliwithdrawalsBtn;
@property (nonatomic, strong) ATMHud *loading;
@property (nonatomic, strong) JXVerifyPayVC *verVC;
@property (nonatomic, strong) NSString *payPassword;
@property (nonatomic, assign) BOOL isAlipay;
@property (nonatomic, strong) NSString *aliUserId;

@property (nonatomic, strong) UITextField *bankTypeTextField;

@property (nonatomic, assign) CGFloat h;

@property (nonatomic, strong) JXPickerView *pickerView;

@property (nonatomic, strong) NSArray *bankTitleArray;
@property (nonatomic, strong) NSArray *bankIdArray;
@property (nonatomic, strong) NSString *bankId;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UILabel *withDrawServiceLabel;

@property (nonatomic, strong) NSDictionary *bankInfoDict;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic,strong) NSString *actualWithDrawMoneyStr;
@property (nonatomic, copy) NSString *drawMoney;

@end

@implementation JXCashWithDrawViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JXMoney_withdrawals");
        
        self.bankTitleArray = @[@"支付宝",
                                       @"中国银行",
                                       @"中国建设银行",
                                       @"中国工商银行",
                                       @"中国农业银行",
                                       @"中国交通银行",
                                       @"中国邮政储蓄",
//                                       @"北京银行",
//                                @"渤海银行",
//                                @"广发银行",
//                                @"恒丰银行",
//                                @"华夏银行",
//                                @"上海银行",
//                                @"温州银行",
//                                @"兴业银行",
//                                @"招商银行",
//                                @"浙商银行",
//                                @"中国光大银行",
//                                @"中国民生银行",
//                                @"中信银行"
        ];
               
        self.bankIdArray = @[@"100", @"101", @"102",@"103",@"104",@"105",@"106"
//                             @"107",@"108",@"109",@"110",@"111",@"112",@"113",@"114",@"115",@"116",@"117",@"118",@"119"
        ];
        
        _array = [NSMutableArray array];
        
        self.selectIndex = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    //先去请求银行卡列表
    long time = (long)[[NSDate date] timeIntervalSince1970];
    NSString *secret = @"";
    
    // 开始网络请求
    [g_server getBindBankCardListWithSecret:secret toView: self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    
//    [self.tableHeader addSubview:self.helpButton];
    
    _h = 10;
    
    JXImageView *cardTypeView = [self createButton:@"选择提现方式" drawTop:YES drawBottom:YES must:NO click:@selector(selctBankCardAction)];
    cardTypeView.frame = CGRectMake(0, _h , JX_SCREEN_WIDTH, HEIGHT);
    _bankTypeTextField = [self createTextField:cardTypeView default:@"" hint:@"请选择银行类型"];
    
    _h += HEIGHT + 10;
    
    [self.tableBody addSubview:self.hideControl];
    [self.tableBody addSubview:self.bgView];
    
//    [self.bgView addSubview:self.targetView];
    [self.bgView addSubview:self.inputView];
    [self.bgView addSubview:self.balanceView];
    self.bgView.frame = CGRectMake(15, _h, bgWidth, CGRectGetMaxY(_balanceView.frame));
    
    _loading = [[ATMHud alloc] init];
    
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];
}

- (void)selctBankCardAction{
    
    if (_array.count == 0) {
        JXAddBankCardAndAlipayVC * addBankCardVC = [[JXAddBankCardAndAlipayVC alloc] init];
        [g_navigation pushViewController:addBankCardVC animated:YES];
        return;
        
    }
    
    //    [g_window addSubview:self.pickerView];
    
    NSDictionary *nameDict = @{@"100" : @"payment_zhifubao",
    @"101" : @"ic_card_boc",
    @"102" : @"ic_card_ccb",
    @"103" : @"ic_card_icbc",
    @"104" : @"ic_card_abc",
    @"105" : @"ic_card_comm",
    @"106" : @"ic_card_psbc",
//   @"107" : @"北京银行_爱给网_aigei_com",
//   @"108" : @"渤海银行_爱给网_aigei_com",
//   @"109" : @"广发银行_爱给网_aigei_com",
//   @"110" : @"恒丰银行_爱给网_aigei_com",
//   @"111" : @"华夏银行_爱给网_aigei_com",
//   @"112" : @"上海银行_爱给网_aigei_com",
//   @"113" : @"温州银行_爱给网_aigei_com",
//   @"114" : @"兴业银行_爱给网_aigei_com",
//   @"115" : @"招商银行_爱给网_aigei_com",
//   @"116" : @"浙商银行_爱给网_aigei_com",
//   @"117" : @"中国光大银行_爱给网_aigei_com",
//   @"118" : @"中国民生银行_爱给网_aigei_com",
//   @"119" : @"中信银行_爱给网_aigei_com"
    };
    
    NSMutableArray *subTitleArray = [NSMutableArray array];
    NSMutableArray *iconImageArray = [NSMutableArray array];
    NSMutableArray *bankTitleArray = [NSMutableArray array];
    //遍历数组
    for (NSDictionary *dict in _array) {
        
        NSString *bankBrandId = [NSString stringWithFormat:@"%@", dict[@"bankBrandId"]];
        [iconImageArray addObject:[nameDict valueForKey: bankBrandId]];
        [bankTitleArray addObject:dict[@"bankBrandName"]];
        if ([bankBrandId isEqualToString:@"100"]) {
            [subTitleArray addObject:@"立即到账"];
        }
        else {
            [subTitleArray addObject:@"2小时内到账"];
        }
    }
    
    //弹出选择的view
    [YZBottomSelectView showBottomSelectViewWithTitle:@"请选择银行卡" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:bankTitleArray subTitlesArray:iconImageArray rightTitleArray:bankTitleArray imageIconArray:iconImageArray selectIndex:self.selectIndex handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
        
        if (index == 0) {
            return ;
        }
        
        index = index - 1;
        //点击确定的回调
        NSString *selectStr = bankTitleArray[index];
        _bankTypeTextField.text = selectStr;
        _bankId = _bankIdArray[index];
        self.bankInfoDict = self.array[index];

    }];
    
}

- (JXPickerView *)pickerView{
    
    if (!_pickerView) {
        _pickerView = [JXPickerView new];
//        _pickerView.didSelect = @selector(comfirmAction);
        _pickerView.delegate = self;
        _pickerView.dataSource =self;
        [_pickerView.confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickerView;
}

- (void)confirmAction {
    
    //点击确定的回调
    NSInteger selectComponent = [self.pickerView.pickerView selectedRowInComponent:0];
    NSString *selectStr = self.array[selectComponent][@"bankBrandName"];
    _bankTypeTextField.text = selectStr;
    _bankId = _bankIdArray[selectComponent];
    [self.pickerView removeFromSuperview];
}


- (JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    
    btn.delegate = self;
    [self.tableBody addSubview:btn];
//    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = g_factory.font18;
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
//        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(30, 0, 130, HEIGHT)];
    p.text = title;
    p.font = g_factory.font15;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
//    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
//        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
//        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, (HEIGHT - 20) / 2, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
//        [iv release];
    }
    return btn;
}

- (UITextField*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH / 2, INSETS, JX_SCREEN_WIDTH / 2 - 50, HEIGHT-INSETS * 2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font15;
    [parent addSubview:p];
//    [p release];
    return p;
}


-(UIButton *)helpButton{
    if(!_helpButton){
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpButton.frame = CGRectMake(JX_SCREEN_WIDTH - 40, JX_SCREEN_TOP - 34, 24, 24);
        NSString *image = THESIMPLESTYLE ? @"im_003_more_button_black" : @"im_003_more_button_normal";
        [_helpButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [_helpButton setImage:[UIImage imageNamed:image] forState:UIControlStateHighlighted];
        [_helpButton addTarget:self action:@selector(helpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpButton;
}

-(UIControl *)hideControl{
    if (!_hideControl) {
        _hideControl = [[UIControl alloc] init];
        _hideControl.frame = CGRectMake(0, _h, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - _h);
        [_hideControl addTarget:self action:@selector(hideControlAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideControl;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIControl alloc] init];
        _bgView.frame = CGRectMake(15, _h, bgWidth, 400);
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

-(UIView *)targetView{
    if (!_targetView) {
        _targetView = [[UIView alloc] init];
        _targetView.frame = CGRectMake(0, 0, bgWidth, drawHei);
        _targetView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
        
        UILabel * targetLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDrawalsTarget")];
        [_targetView addSubview:targetLabel];
        
        CGRect btnFrame = CGRectMake(CGRectGetMaxX(targetLabel.frame)+20, 0, bgWidth-CGRectGetMaxX(targetLabel.frame)-20-drawMarginX, drawHei);
        _cardButton = [UIFactory createButtonWithRect:btnFrame title:@"微信号(8868)" titleFont:g_factory.font15 titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(cardButtonAction:) target:self];
        [_targetView addSubview:_cardButton];
    }
    return _targetView;
}

-(UIView *)inputView{
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.frame = CGRectMake(0, 0, bgWidth, 126);
        _inputView.backgroundColor = [UIColor whiteColor];
        
        UILabel * cashTitle = [UIFactory createLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDAmount")];
        [_inputView addSubview:cashTitle];
        
        UILabel * rmbLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame), 35, 35) text:@"¥"];
        rmbLabel.font = g_factory.font28b;
        rmbLabel.textAlignment = NSTextAlignmentLeft;
        [_inputView addSubview:rmbLabel];
        
        _countTextField = [UIFactory createTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame), CGRectGetMinY(rmbLabel.frame), bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX, drawHei) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont boldSystemFontOfSize:45] color:[UIColor blackColor] delegate:self];
        _countTextField.borderStyle = UITextBorderStyleNone;
        [_inputView addSubview:_countTextField];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_countTextField.frame)+5, bgWidth-drawMarginX*2, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_inputView addSubview:line];
        
    }
    return _inputView;
}

-(UIView *)balanceView{
    if (!_balanceView) {
        _balanceView = [[UIView alloc] init];
        _balanceView.frame = CGRectMake(0, CGRectGetMaxY(_inputView.frame), bgWidth, 185 + 10);
        _balanceView.backgroundColor = [UIColor whiteColor];

        NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f，",Localized(@"JXMoney_blance"),g_App.myMoney];
        
        _balanceLabel = [UIFactory createLabelWith:CGRectZero text:moneyStr font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
        CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
        _balanceLabel.frame = CGRectMake(drawMarginX, 0, blanceWidth, 50);
        [_balanceView addSubview:_balanceLabel];
        
        _drawAllBtn = [UIFactory createButtonWithRect:CGRectZero title:@"全部提现" titleFont:_balanceLabel.font titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(drawAllBtnAction) target:self];
        CGFloat drawWidth = [_drawAllBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_drawAllBtn.titleLabel.font}].width;
        _drawAllBtn.frame = CGRectMake(CGRectGetMaxX(_balanceLabel.frame)+10, CGRectGetMinY(_balanceLabel.frame), drawWidth, 50);
        [_balanceView addSubview:_drawAllBtn];
        
        _withdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:@"确认提现" titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
        _withdrawalsBtn.tag = 1000;
        _withdrawalsBtn.frame = CGRectMake(20, CGRectGetMaxY(_balanceLabel.frame)+10, bgWidth-20*2, 44);
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:THEMECOLOR] forState:UIControlStateNormal];
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _withdrawalsBtn .layer.cornerRadius = 22;
        _withdrawalsBtn.clipsToBounds = YES;
        
        [_balanceView addSubview:_withdrawalsBtn];
        
        
        _aliwithdrawalsBtn = [UIFactory createButtonWithRect:CGRectZero title:@"全部提现" titleFont:g_factory.font17 titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
        _aliwithdrawalsBtn.tag = 1011;
        _aliwithdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame)+20+60, bgWidth-drawMarginX*2, 50);
        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _aliwithdrawalsBtn .layer.cornerRadius = 5;
        _aliwithdrawalsBtn.clipsToBounds = YES;
        
//        [_balanceView addSubview:_aliwithdrawalsBtn];
        
        UILabel *noticeLabel = [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(_withdrawalsBtn.frame) , bgWidth-drawMarginX*2, 20) text:Localized(@"JXMoney_withDNotice") font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
//        [_balanceView addSubview:noticeLabel];
        
        _withDrawServiceLabel =  [UIFactory createLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(noticeLabel.frame), bgWidth-drawMarginX*2, 30) text:@"提现手续费为1.0%, 最低提现费用为1元" font:g_factory.font14 textColor:[UIColor lightGrayColor] backgroundColor:nil];
        _withDrawServiceLabel.textAlignment = NSTextAlignmentLeft;
        [_balanceView addSubview:_withDrawServiceLabel];
    }
    return _balanceView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == _countTextField) {
        NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        // 计算手续费
        CGFloat amount = [toString floatValue];
        CGFloat rate = [[g_default objectForKey:kPayRate] floatValue];
        rate = rate == 0 ? 0.01 : rate;
        CGFloat serviceAmount = amount > 1 ? amount * rate : 1;
//        _withDrawServiceLabel.text = [NSString stringWithFormat:@"提现手续费:%.2f", serviceAmount];
        
        if (toString.length > 0) {
            NSString *stringRegex = @"(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,4}(([.]\\d{0,2})?)))?";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
            if (![predicate evaluateWithObject:toString]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField == _bankTypeTextField){
        
        
        [self.view endEditing:YES];
//        [g_window addSubview:self.pickerView];
//        self.pickerView.hidden = NO;
        if (_array.count == 0) {
            JXAddBankCardAndAlipayVC * addBankCardVC = [[JXAddBankCardAndAlipayVC alloc] init];
            [g_navigation pushViewController:addBankCardVC animated:YES];
            return NO;
            
        }
        NSDictionary *nameDict = @{@"100" : @"payment_zhifubao",
        @"101" : @"ic_card_boc",
        @"102" : @"ic_card_ccb",
        @"103" : @"ic_card_icbc",
        @"104" : @"ic_card_abc",
        @"105" : @"ic_card_comm",
        @"106" : @"ic_card_psbc",
//                                   @"107" : @"北京银行_爱给网_aigei_com",
//                                   @"108" : @"渤海银行_爱给网_aigei_com",
//                                   @"109" : @"广发银行_爱给网_aigei_com",
//                                   @"110" : @"恒丰银行_爱给网_aigei_com",
//                                   @"111" : @"华夏银行_爱给网_aigei_com",
//                                   @"112" : @"上海银行_爱给网_aigei_com",
//                                   @"113" : @"温州银行_爱给网_aigei_com",
//                                   @"114" : @"兴业银行_爱给网_aigei_com",
//                                   @"115" : @"招商银行_爱给网_aigei_com",
//                                   @"116" : @"浙商银行_爱给网_aigei_com",
//                                   @"117" : @"中国光大银行_爱给网_aigei_com",
//                                   @"118" : @"中国民生银行_爱给网_aigei_com",
//                                   @"119" : @"中信银行_爱给网_aigei_com"
        };
        
        NSMutableArray *subTitleArray = [NSMutableArray array];
        NSMutableArray *iconImageArray = [NSMutableArray array];
        NSMutableArray *bankTitleArray = [NSMutableArray array];
        NSMutableArray *bankCardArray = [NSMutableArray array];
        
        //遍历数组
        for (NSDictionary *dict in _array) {
            
            NSString *bankBrandId = [NSString stringWithFormat:@"%@", dict[@"bankBrandId"]];
            [iconImageArray addObject:[nameDict valueForKey: bankBrandId]];
            [bankTitleArray addObject:dict[@"bankBrandName"]];
            if ([bankBrandId isEqualToString:@"100"]) {
                [subTitleArray addObject:@"立即到账"];
            }
            else {
                [subTitleArray addObject:@"2小时内到账"];
            }
            [bankCardArray addObject:dict[@"cardNo"]];
        }
        
        //弹出选择的view
        [YZBottomSelectView showBottomSelectViewWithTitle:@"请选择银行卡" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:bankTitleArray subTitlesArray:subTitleArray rightTitleArray:bankCardArray imageIconArray:iconImageArray selectIndex:self.selectIndex handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            
            if (index == 0) {
                return ;
            }
            
            index = index - 1;
            self.selectIndex = index;
            //点击确定的回调
            NSString *selectStr = bankTitleArray[index];
            _bankTypeTextField.text = selectStr;
            _bankId = _bankIdArray[index];
            _bankInfoDict = self.array[index];
        }];
        
        return NO;
    }
    else{
        self.pickerView.hidden = YES;
        return YES;
    }
}

#pragma mark - pickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.array.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary *dict = self.array[row];
    return dict[@"bankBrandName"];
}


#pragma mark Action

-(void)cardButtonAction:(UIButton *)button{
    
}

-(void)drawAllBtnAction{
    
    NSString * allMoney = [NSString stringWithFormat:@"%.2f",g_App.myMoney];
    
    // 计算手续费
    CGFloat amount = [allMoney floatValue];
    
    CGFloat rate = [[g_default objectForKey:kPayRate] floatValue];
    rate = rate == 0 ? 0.01 : rate;
    CGFloat serviceAmount = amount > 100 ? amount * rate : 1;
    serviceAmount = serviceAmount > 1 ? serviceAmount : 1;
    CGFloat actualWithDrawoney = amount - serviceAmount;
    
    NSString *actualWithdrawStr = [NSString stringWithFormat:@"%.2f", actualWithDrawoney];
    self.actualWithDrawMoneyStr = actualWithdrawStr;
    _countTextField.text = allMoney;
}

-(void)withdrawalsBtnAction:(UIButton *)button{
    
    if ([_countTextField.text isEqualToString:@""]) {
        [g_server showMsg:@"请输入提现金额"];
        return ;
    }
    if (_array.count == 0) {
        [g_server showMsg:@"请先添加银行卡"];
        JXAddBankCardAndAlipayVC * addBankCardVC = [[JXAddBankCardAndAlipayVC alloc] init];
        [g_navigation pushViewController:addBankCardVC animated:YES];
        return ;
    }
    if (!self.bankInfoDict) {
        [g_server showMsg:@"请选择提现方式"];
        return ;
    }
    NSString * allMoney = [NSString stringWithFormat:@"%.2f",g_App.myMoney];
    
    NSString *amontStr = _countTextField.text;
    if ([_countTextField.text isEqualToString:allMoney]) {
        amontStr = self.actualWithDrawMoneyStr;
    }
    
    // 计算手续费
    CGFloat amount = [amontStr floatValue];
    CGFloat rate = [[g_default objectForKey:kPayRate] floatValue];
    rate = rate == 0 ? 0.01 : rate;
    CGFloat serviceAmount = amount > 1 ? amount * rate : 1;
    serviceAmount = serviceAmount > 1 ? serviceAmount : 1;
    NSString *drawServiceLabel = [NSString stringWithFormat:@"提现手续费:%.2f", serviceAmount];
    NSString *moneyAmountLabel =  [NSString stringWithFormat:@"提现金额:%.2f", amount];
    self.drawMoney = [NSString stringWithFormat:@"%.2f",amount];
    CGFloat allFloat = [allMoney floatValue];
    CGFloat amountFloat = [amontStr floatValue];
    CGFloat realAmountFloat = amountFloat + (rate *amountFloat);
    if (realAmountFloat > allFloat) {
        [g_App showAlert:@"余额不足"];
        return;
    }
    CGFloat actualWithDrawoney = amount + serviceAmount;
    NSString *actualWithdrawStr = [NSString stringWithFormat:@"￥%.2f", actualWithDrawoney];
    NSDictionary *confirmInfoDict = @{@"withDrawMoney" : moneyAmountLabel,
                                      @"serviceMoney" : drawServiceLabel,
                                      @"bankResult" : self.bankInfoDict,
                                      @"amount" : actualWithdrawStr
    };
    
    
    //先弹框提示
    
    [self.view endEditing:YES];
    [JXWithDrawConfirmView showConfirmViewWithDict:confirmInfoDict confirmBlock:^{
        
        if ([_countTextField.text doubleValue] < 0.5) {
            [g_App showAlert:Localized(@"JX_Least0.5")];
            return;
        }
        
        if ([_countTextField.text doubleValue] > g_App.myMoney) {
            [g_App showAlert:@"余额不足"];
            return;
        }
        
        if ([g_server.myself.isPayPassword boolValue]) {
            
            self.isAlipay = button.tag == 1011;
            self.verVC = [JXVerifyPayVC alloc];
            self.verVC.type = JXVerifyTypeWithdrawal;
//            self.verVC.RMB = self.countTextField.text;
            self.verVC.RMB = [NSString stringWithFormat:@"%.2f", actualWithDrawoney];

            self.verVC.delegate = self;
            self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
            self.verVC.didVerifyPay = @selector(didVerifyPay:);
            self.verVC = [self.verVC init];
            
            [self.view addSubview:self.verVC.view];
        }
        else {
            JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
            payPswVC.type = JXPayTypeSetupPassword;
            payPswVC.enterType = JXEnterTypeWithdrawal;
            payPswVC = [payPswVC init];
            [g_navigation pushViewController:payPswVC animated:YES];
        }
        
        
        
    }];
    
//    NSString *amontStr = _countTextField.text;
//    // 计算手续费
//    CGFloat amount = [amontStr floatValue];
//    CGFloat rate = [[g_default objectForKey:kPayRate] floatValue];
//    rate = rate == 0 ? 0.01 : rate;
//
//    CGFloat serviceAmount = amount * rate > 1 ? amount * rate : 1;
//    NSString *drawServiceLabel = [NSString stringWithFormat:@"提现手续费:%.2f", serviceAmount];
//    NSString *moneyAmountLabel =  [NSString stringWithFormat:@"提现金额:%.2f", amount];
//
//    CGFloat currentAmount = amount - serviceAmount;
//
//    if ([_countTextField.text doubleValue] < 0.5) {
//        [g_App showAlert:Localized(@"JX_Least0.5")];
//        return;
//    }
//    if ([_countTextField.text doubleValue] > g_App.myMoney) {
//        [g_App showAlert:@"余额不足"];
//        return;
//    }
//    if ([g_server.myself.isPayPassword boolValue]) {
//
//        self.isAlipay = button.tag == 1011;
//        self.verVC = [JXVerifyPayVC alloc];
//        self.verVC.type = JXVerifyTypeWithdrawal;
//
//        //去掉手续费
//        self.verVC.RMB = [NSString stringWithFormat:@"%f", currentAmount];
//        self.verVC.delegate = self;
//        self.verVC.didDismissVC = @selector(dismissVerifyPayVC);
//        self.verVC.didVerifyPay = @selector(didVerifyPay:);
//        self.verVC = [self.verVC init];
//
//        [self.view addSubview:self.verVC.view];
//    }
//    else {
//        JXPayPasswordVC *payPswVC = [JXPayPasswordVC alloc];
//        payPswVC.type = JXPayTypeSetupPassword;
//        payPswVC.enterType = JXEnterTypeWithdrawal;
//        payPswVC = [payPswVC init];
//        [g_navigation pushViewController:payPswVC animated:YES];
//    }
    
//    // 绑定微信
//    SendAuthReq* req = [[SendAuthReq alloc] init];
//    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    // app名称
//    NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//    req.state = titleStr;
//    req.openID = AppleId;
//    
//    [WXApi sendAuthReq:req
//        viewController:self
//              delegate:[WXApiManager sharedManager]];
    
}

- (void)didVerifyPay:(NSString *)sender {
    
    self.payPassword = [NSString stringWithString:sender];

//    if (self.isAlipay) {
//        [g_server getAliPayAuthInfoToView:self];
//    }
//    else {
//        // 绑定微信
//        SendAuthReq* req = [[SendAuthReq alloc] init];
//        req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        // app名称
//        NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//        req.state = titleStr;
//        req.openID = g_App.config.appleId;
//
//        [WXApi sendAuthReq:req
//            viewController:self
//                  delegate:[WXApiManager sharedManager]];
//    }
    
    long time = (long)[[NSDate date] timeIntervalSince1970];
    NSString *secret = @"";
    NSString *money =  _countTextField.text;
    [g_server applyWithDraw:secret cardId:_bankId  money:self.drawMoney toView:self];
    
}

- (void)dismissVerifyPayVC {
    [self.verVC.view removeFromSuperview];
    [g_navigation popToViewController:[JXMyMoneyViewController class] animated:true];
}



// 用户绑定微信，获取openid
- (void)getWeChatTokenThenGetUserInfoWithCode:(NSString *)code {

    [_loading start];
    [g_server userBindWXCodeWithCode:code toView:self];
}

-(void)hideControlAction{
    [_countTextField resignFirstResponder];
}

-(void)actionQuit{
    [_countTextField resignFirstResponder];
    [super actionQuit];
}
-(void)helpButtonAction{
    
}


- (void)alipayGetUserId:(NSNotification *)noti {
    [g_server aliPayUserId:noti.object toView:self];
}


- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
//    [_wait stop];
    if ([aDownload.action isEqualToString:act_UserBindWXCode]) {
        
        NSString *amount = [NSString stringWithFormat:@"%d",(int)([_countTextField.text doubleValue] * 100)];
        long time = (long)[[NSDate date] timeIntervalSince1970];

        NSString *secret = [self secretEncryption:dict[@"openid"] amount:amount time:time payPassword:self.payPassword];
        [g_server transferWXPayWithAmount:amount secret:secret time:[NSNumber numberWithLong:time] toView:self];

    }else if ([aDownload.action isEqualToString:act_TransferWXPay]) {
        [_loading stop];
        [self dismissVerifyPayVC];  // 销毁支付密码界面
        [g_App showAlert:Localized(@"JX_WithdrawalSuccess")];
        _countTextField.text = nil;
        [g_server getUserMoenyToView:self];
    }
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        _balanceLabel.text = [NSString stringWithFormat:@"%@¥%.2f，",Localized(@"JXMoney_blance"),g_App.myMoney];
        [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
    }
    if ([aDownload.action isEqualToString:act_aliPayUserId]) {
        long time = (long)[[NSDate date] timeIntervalSince1970];
        NSString *secret = [self secretEncryption:self.aliUserId amount:_countTextField.text time:time payPassword:self.payPassword];
        [g_server alipayTransfer:self.countTextField.text secret:secret time:@(time) toView:self];
    }
    if ([aDownload.action isEqualToString:act_alipayTransfer]) {
        [g_server showMsg:Localized(@"JX_WithdrawalSuccess")];
        [g_navigation dismissViewController:self animated:YES];
    }
    
    if ([aDownload.action isEqualToString:act_WithDraw]) {
        
        [g_server showMsg:Localized(@"JX_WithdrawalSuccess")];
    }
    
    if([aDownload.action isEqualToString:act_GetBankCardList]){
        
        // 将数组转成model
        
        [_array removeAllObjects];
        [_array addObjectsFromArray:array1];
        
        // 设置第一个银行卡
        if (array1.count <= 0) {
            return ;
        }
        
        NSDictionary *dict = array1[0];
        _bankTypeTextField.text = dict[@"bankBrandName"];
        self.bankInfoDict = dict;

        
        [self.pickerView.pickerView reloadAllComponents];
        _bankId = dict[@"id"];

    }
    
    if([aDownload.action isEqualToString:act_WithDraw]) {
        
        [self dismissVerifyPayVC];
    }

    if ([aDownload.action isEqualToString:act_getAliPayAuthInfo]) {
        NSString *aliId = [dict objectForKey:@"aliUserId"];
        NSString *authInfo = [dict objectForKey:@"authInfo"];
        if (IsStringNull(aliId)) {
            NSString *appScheme = @"zhiliaoapp";


        }else {
            long time = (long)[[NSDate date] timeIntervalSince1970];
            NSString *secret = [self secretEncryption:aliId amount:_countTextField.text time:time payPassword:self.payPassword];
            [g_server alipayTransfer:self.countTextField.text secret:secret time:@(time) toView:self];
        }
    }

}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_loading stop];
    if ([aDownload.action isEqualToString:act_alipayTransfer]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.verVC clearUpPassword];
        });
    }
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_loading stop];
    return hide_error;
}

- (NSString *)secretEncryption:(NSString *)openId amount:(NSString *)amount time:(long)time payPassword:(NSString *)payPassword {
    NSString *secret = [NSString string];
    
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:openId];
    [str1 appendString:MY_USER_ID];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:g_server.access_token];
    [str2 appendString:amount];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    str2 = [[g_server getMD5String:str2] mutableCopy];
    
    [str1 appendString:str2];
    NSMutableString *str3 = [NSMutableString string];
    str3 = [[g_server getMD5String:payPassword] mutableCopy];
    [str1 appendString:str3];
    
    secret = [g_server getMD5String:str1];
    
    return secret;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

@end
