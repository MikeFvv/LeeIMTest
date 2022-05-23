//
//  JXAddBankCardViewController.m
//  shiku_im
//
//  Created by aaa on 2019/12/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXAddBankCardViewController.h"
#import "JXPickerView.h"
#import "YZBottomSelectView.h"
#import "versionManage.h"
@interface JXAddBankCardViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UITextField *cardholderTextField;
@property (nonatomic, strong) UITextField *bankTypeTextField;
@property (nonatomic, strong) UITextField *cardNumTextField;
@property (nonatomic, strong) UITextField *cardAddressField;
@property (nonatomic, strong) UITextField *idcardTextField;
@property (nonatomic, strong) UITextField *iphoneField;
@property (nonatomic, strong) NSArray *bankTitleArray;
@property (nonatomic, strong) NSArray *bankIdArray;
@property (nonatomic, strong) NSString *bankId;



@property (nonatomic, strong) JXPickerView *pickerView;

@property (nonatomic, strong) UIView *selectView;

@property (nonatomic, assign) NSInteger selectIndex;


@end

#define HEIGHT 56

@implementation JXAddBankCardViewController

- (instancetype)init{
    
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        
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
//                                @"中国广大银行",
//                                @"中国民生银行",
//                                @"中信银行"
        ];
               
        self.bankIdArray = @[@"100", @"101", @"102",@"103",@"104",@"105",@"106",
//                             @"107",@"108",@"109",@"110",@"111",@"112",@"113",@"114",@"115",@"116",@"117",@"118",@"119"
        ];
        
        self.selectIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

//    self.heightHeader = 0;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.header.hidden = YES;
    self.tableView.bounces = NO;

    
    self.title = Localized(@"添加银行卡/支付宝");

    CGFloat h = 0;
    
    JXImageView *nameImageView = [self createButton:Localized(@"持卡人") drawTop:YES drawBottom:YES must:YES click:nil];
    nameImageView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _cardholderTextField = [self createTextField:nameImageView isShowRightView:false default:@"" hint:Localized(@"请输入持卡人姓名")];
    
    h += HEIGHT;
    
    JXImageView *idcard = [self createButton:Localized(@"身份证") drawTop:YES drawBottom:YES must:YES click:nil];
    idcard.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _idcardTextField = [self createTextField:idcard isShowRightView:false default:@"" hint:Localized(@"请输入持卡人身份证号")];
    
    h += HEIGHT;
    
    JXImageView *iPhone = [self createButton:Localized(@"手机号") drawTop:YES drawBottom:YES must:YES click:nil];
    iPhone.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _iphoneField = [self createTextField:iPhone isShowRightView:false default:@"" hint:Localized(@"请输入持卡人手机号")];
    
    h += HEIGHT;
    
    
    
    JXImageView *cardNumView = [self createButton:Localized(@"卡号") drawTop:YES drawBottom:YES must:YES click:nil];
    cardNumView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _cardNumTextField = [self createTextField:cardNumView isShowRightView:false default:@"" hint:Localized(@"请输入卡号")];
    
    h += HEIGHT;
    
//    JXImageView *cardTypeView = [self createButton:@"银行/支付宝" drawTop:YES drawBottom:YES must:YES click:nil];
//    cardTypeView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    _bankTypeTextField = [self createTextField:cardTypeView isShowRightView:true default:@"" hint:@"请选择银行/支付宝"];
    JXImageView *cardTypeView = [self createButton:Localized(@"银行") drawTop:YES drawBottom:YES must:YES click:nil];
    cardTypeView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _bankTypeTextField = [self createTextField:cardTypeView isShowRightView:true default:@"" hint:Localized(@"请选择银行")];
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    _selectView.backgroundColor = HEXCOLOR(0xf0eff4);
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    
    h += HEIGHT;
    
    JXImageView *cardAddressView = [self createButton:Localized(@"银行开户地") drawTop:YES drawBottom:YES must:NO click:nil];
    cardAddressView.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _cardAddressField = [self createTextField:cardAddressView isShowRightView:false default:@"" hint:Localized(@"请输入银行开户地")];
    
    h += HEIGHT + 20;
    
    UIButton *bindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bindButton.backgroundColor = THEMECOLOR;
    [bindButton setTitle:Localized(@"绑定") forState:UIControlStateNormal];
    bindButton.layer.cornerRadius = 22;
    bindButton.layer.masksToBounds = YES;
    [bindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bindButton.frame = CGRectMake(20, h+15, JX_SCREEN_WIDTH - 40, 44);
    [bindButton addTarget:self action:@selector(bindBankCard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView addSubview:bindButton];
    
}

- (void)bindBankCard{
    
    if ([_cardholderTextField.text isEqualToString:@""]) {
        
        [g_server showMsg:@"请填写姓名"];
        return;
    }
    
    if ([_cardNumTextField.text isEqualToString:@""]) {
        
        [g_server showMsg:@"请填写卡号"];
        return;
    }
    
    if ([_idcardTextField.text isEqualToString:@""]) {

        [g_server showMsg:@"请填写身份证号"];
        return;
    }
    if ([_iphoneField.text isEqualToString:@""]) {

        [g_server showMsg:@"请填写手机号"];
        return;
    }
    if ([_bankTypeTextField.text isEqualToString:@""]) {
           
        [g_server showMsg:@"请选择银行类型"];
        return;
    }
    
    [self addBankMethod];
//    [self setFourElements];
    
//    NSString *appcode = @"a23abca5d8c4466ca8fff9f90568476b";
//    NSString *host = @"https://bankcard4c.shumaidata.com";
//    NSString *path = @"/bankcard4c";
//    NSString *method = @"GET";
//    NSString *querys = [NSString stringWithFormat:@"?bankcard=%@&idcard=%@&mobile=%@&name=%@",_cardNumTextField.text,_idcardTextField.text,_iphoneField.text,_cardholderTextField.text];
//    NSString *url = [NSString stringWithFormat:@"%@%@%@",  host,  path , querys];
//    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval: 5];
//    request.HTTPMethod  =  method;
//    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
//    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
//        completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
//             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:nil];
//        if ([dict[@"code"]integerValue]==200) {
//            if ([dict[@"data"][@"result"]integerValue]==0) {
//                //验证成功
////                 回到主线程
//                //上传结束
//                [task suspend];
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [self addBankMethod];
//                    [self setFourElements];
//                });
//            }else{
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [g_server showMsg:@"请确保数据的真实性"];
//                });            }
//        }else{
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [g_server showMsg:@"请确保数据的真实性"];
//            });
//        }
//        }];
//
//    [task resume];
}
-(void)addBankMethod{
    // 开始网络请求
    NSString *bandCradId = _bankId;
    NSString *cardNo = _cardNumTextField.text;
    NSString *userName = _cardholderTextField.text;
    NSString *openCardAddress = _cardAddressField.text;

    long time = (long)[[NSDate date] timeIntervalSince1970];
    NSString *secret = [self getSecretWithtime:time];
    [g_server bindBankCardWithBankBrandId:bandCradId secret:secret cardNo:cardNo userName:userName openCradAddress:openCardAddress toView:self];
}
-(void)setFourElements{
    [g_server UpdateFourElementsToView:self];
}
- (NSString *)getSecretWithtime:(long)time {
    
    return @"";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField == _bankTypeTextField){
        
        [self.view endEditing:YES];
//        [g_window addSubview:self.pickerView];
//        self.pickerView.hidden = NO;
        
        
        NSArray *imageArray = @[@"treasure",
                               @"ic_card_boc",
                               @"ic_card_ccb",
                              @"ic_card_icbc",
                             @"ic_card_abc",
                            @"ic_card_comm",
                            @"ic_card_psbc",
//                                @"北京银行_爱给网_aigei_com",
//                                @"渤海银行_爱给网_aigei_com",
//                                @"广发银行_爱给网_aigei_com",
//                                @"恒丰银行_爱给网_aigei_com",
//                                @"华夏银行_爱给网_aigei_com",
//                                @"上海银行_爱给网_aigei_com",
//                                @"温州银行_爱给网_aigei_com",
//                                @"兴业银行_爱给网_aigei_com",
//                                @"招商银行_爱给网_aigei_com",
//                                @"浙商银行_爱给网_aigei_com",
//                                @"中国光大银行_爱给网_aigei_com",
//                                @"中国民生银行_爱给网_aigei_com",
//                                @"中信银行_爱给网_aigei_com"
        ];
        
        NSArray *subTitlesArray = @[@"立即到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账",
                                    @"2小时内到账"
        ];
        
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
        
        
        
        //弹出选择的view
        [YZBottomSelectView showBottomSelectViewWithTitle:@"请选择银行卡" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:_bankTitleArray subTitlesArray:subTitlesArray rightTitleArray:nil imageIconArray:imageArray selectIndex: self.selectIndex  handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            
            if (index == 0) {
                return ;
            }
            
            index = index - 1;
            self.selectIndex = index;
            //点击确定的回调
               NSString *selectStr = self.bankTitleArray[index];
               _bankTypeTextField.text = selectStr;
               _bankId = _bankIdArray[index];
        }];
        
        return NO;
    }
    else{
        self.pickerView.hidden = YES;
        return YES;
    }
}

- (void)didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    [_wait hide];
    
    if([aDownload.action isEqualToString:act_BindBankCard]){
        
        [g_server showMsg:@"绑定成功"];
        [g_navigation dismissViewController:self animated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getfourElements" object:nil];
        
    }
    if ([aDownload.action isEqualToString:setUpdateFourElements]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getfourElements" object:nil];
    }
    
   
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    [_wait hide];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
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
    NSString *selectStr = self.bankTitleArray[selectComponent];
    _bankTypeTextField.text = selectStr;
    _bankId = _bankIdArray[selectComponent];
    [self.pickerView removeFromSuperview];
    
}

#pragma mark - pickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.bankTitleArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.bankTitleArray[row];
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
    [self.tableView addSubview:btn];
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
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
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

- (UITextField*)createTextField:(UIView*)parent isShowRightView:(BOOL)showRightView default:(NSString*)s hint:(NSString*)hint{
    
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH / 2,INSETS,JX_SCREEN_WIDTH / 2, HEIGHT-INSETS * 2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = g_factory.font15;
    [parent addSubview:p];
    
    if(showRightView) {
        
        UIImageView *arrowImageView = [UIImageView new];
        arrowImageView.image = [UIImage imageNamed:@"set_list_next"];
        
        p.rightView = arrowImageView;
        p.rightViewMode = UITextFieldViewModeAlways;
        p.frame = CGRectMake(JX_SCREEN_WIDTH / 2, INSETS, JX_SCREEN_WIDTH / 2 - 20, HEIGHT-INSETS * 2);
    }
    
    
//    [p release];
    return p;
}


@end
