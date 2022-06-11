//
//  inputPhoneVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "inputPhoneVC.h"
#import "inputPwdVC.h"
#import "JXTelAreaListVC.h"
#import "JXUserObject.h"
#import "PSRegisterBaseVC.h"
#import "resumeData.h"
#import "webpageVC.h"
#import "UIView+Frame.h"
#import "RITLUtility.h"

#define HEIGHT 46
#define MarginWidth 24

@interface inputPhoneVC ()<UITextFieldDelegate>
{
    NSTimer *_timer;
    UIButton *_areaCodeBtn;
    JXUserObject *_user;
    UIImageView * _imgCodeImg;
    UITextField *_imgCode;   //图片验证码
    UIButton * _graphicButton;
    UIButton* _skipBtn;
    BOOL _isSkipSMS;
    BOOL _isSendFirst;
    // 同意协议勾选
    UIImageView * _agreeImgV;
}
//@property (nonatomic, strong) UIView *imgCodeView;
@property (nonatomic, assign) BOOL isSmsRegister;
@property (nonatomic, assign) BOOL isCheckToSMS;  // YES:发送短信处验证手机号  NO:注册处验证手机号
@property (nonatomic ,strong)UILabel *areaLabel;
@property (nonatomic ,strong)UIImageView *bgImageview;
@end

@implementation inputPhoneVC

- (id)init
{
    self = [super init];
    if (self) {
        _seconds = 0;
        self.isGotoBack   = NO;
//        self.title = Localized(@"JX_Register");
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
//        self.tableBody.backgroundColor = [UIColor whiteColor];
        self.tableBody.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardToView)];
        [self.tableBody addGestureRecognizer:tap];
        _isSendFirst = YES;  // 第一次发送短信
        int n = INSETS;
        int distance = 50; // 左右间距
        self.isSmsRegister = NO;
        //酷聊icon
        n += 50;
        
//        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(0, n, JX_SCREEN_WIDTH, 34)];
//        titleL.text = [NSString stringWithFormat:@"%@ %@",Localized(@"JX_Register"),XL_APP_NAME];
//        titleL.font = [UIFont systemFontOfSize:30];
//        titleL.textAlignment = NSTextAlignmentCenter;
//        [titleL setTextColor:[UIColor whiteColor]];
//        [self.tableBody addSubview:titleL];
        
//        UIImageView * kuliaoIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"酷聊120"]];
//        kuliaoIconView.frame = CGRectMake((JX_SCREEN_WIDTH-80)/2, n, 95, 95);
//        [self.tableBody addSubview:kuliaoIconView];
        
        //手机号
        n += 30+50;
        
        UILabel *areaL = [UIFactory createLabelWith:CGRectMake(50, n,JX_SCREEN_WIDTH-100, HEIGHT) text:@""];
        areaL.font = g_factory.font16;
        [areaL setTextColor:[UIColor whiteColor]];
        [self.tableBody addSubview:areaL];
        self.areaLabel = areaL;
        
//        UIImageView *rightArraw  =[[UIImageView alloc]initWithFrame:CGRectMake( areaL.width-20, (HEIGHT-20)*0.5, 20, 20)];
//        rightArraw.image = [UIImage imageNamed:@"set_list_next"];
//        [areaL addSubview:rightArraw];
        
//        UIView *areaLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, areaL.frame.size.width, 0.5)];
//         areaLine.backgroundColor = HEXCOLOR(0xD6D6D6);
//         [areaL addSubview:areaLine];
        
//        UITapGestureRecognizer *areaTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(areaCodeBtnClick:)];
//        areaL.userInteractionEnabled = YES;
//        [areaL addGestureRecognizer:areaTap];
        
        n = n+HEIGHT+INSETS+50;
        
        if (!_phone) {
            NSString *placeHolder;
            if ([g_config.regeditPhoneOrName intValue] == 0) {
                self.areaLabel.hidden = YES;
                placeHolder = Localized(@"JX_InputPhone");
            }else {
                self.areaLabel.hidden = YES;
                placeHolder = Localized(@"JX_InputUserAccount");
            }
            _phone = [UIFactory createTextFieldWith:CGRectMake(MarginWidth, n, self_width-MarginWidth*2, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:placeHolder font:g_factory.font16];
            _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            _phone.borderStyle = UITextBorderStyleNone;
            if ([g_config.regeditPhoneOrName intValue] == 1) {
                _phone.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
            }else {
                _phone.keyboardType = UIKeyboardTypeNumberPad;  // 限制只能数字输入，使用数字键盘
            }
            _phone.layer.cornerRadius = HEIGHT/2;
            _phone.backgroundColor =  RITLColorFromIntRBG(244, 246, 248);
            _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
            [_phone addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
            [_phone setTextColor:[UIColor blackColor]];
            [self.tableBody addSubview:_phone];
            
            
            UIView *idLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
            _phone.leftView = idLeftView;
            _phone.leftViewMode = UITextFieldViewModeAlways;
            UIButton *idLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
            [idLeftBtn setBackgroundImage:[UIImage imageNamed:@"login_id"] forState:UIControlStateNormal];
            [idLeftView addSubview:idLeftBtn];
            
            
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, _phone.frame.size.width, 0.5)];
//            line.backgroundColor = HEXCOLOR(0xD6D6D6);
//            [_phone addSubview:line];
            

        }
        n = n+HEIGHT+INSETS;
        //密码
        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(MarginWidth, n, JX_SCREEN_WIDTH-MarginWidth*2, HEIGHT)];
        _pwd.delegate = self;
        _pwd.font = g_factory.font16;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPassWord") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _pwd.secureTextEntry = YES;
        _pwd.userInteractionEnabled = YES;
        [_pwd setTextColor:[UIColor blackColor]];
        _pwd.layer.cornerRadius = HEIGHT/2;
        _pwd.backgroundColor =  RITLColorFromIntRBG(244, 246, 248);
        
        UIView *pwLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        _pwd.leftView = pwLeftView;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        UIButton *pwLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
        [pwLeftBtn setBackgroundImage:[UIImage imageNamed:@"login_pw"] forState:UIControlStateNormal];
        [pwLeftView addSubview:pwLeftBtn];
        
        UIView *eyeView = [[UIView alloc]initWithFrame:CGRectMake(_pwd.frame.size.width-60, 0, 40, 40)];
        _pwd.rightView = eyeView;
        _pwd.rightViewMode = UITextFieldViewModeAlways;
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 20, 16)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"ic_password_hide"] forState:UIControlStateNormal];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"ic_password_display"] forState:UIControlStateSelected];
        [rightBtn addTarget:self action:@selector(passWordRightViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [eyeView addSubview:rightBtn];
        
        [self.tableBody addSubview:_pwd];
        

//        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, _pwd.frame.size.width, 0.5)];
//        verticalLine.backgroundColor = HEXCOLOR(0xD6D6D6);
//        [_pwd addSubview:verticalLine];
        
        n = n+HEIGHT+INSETS;
        
        //图片验证码
        _imgCode = [UIFactory createTextFieldWith:CGRectMake(distance, n, self_width-distance*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
        _imgCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_inputImgCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _imgCode.borderStyle = UITextBorderStyleNone;
        _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.tableBody addSubview:_imgCode];

        
        UIView *imCLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, _phone.frame.size.width, 0.5)];
        imCLine.backgroundColor = HEXCOLOR(0xD6D6D6);
        [_imgCode addSubview:imCLine];
        
        _imgCodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCode.frame)+INSETS, 0, 70, 35)];
        _imgCodeImg.center = CGPointMake(_imgCodeImg.center.x, _imgCode.center.y);
        _imgCodeImg.userInteractionEnabled = YES;
        [self.tableBody addSubview:_imgCodeImg];
        
        UIView *imgCodeLine = [[UIView alloc] initWithFrame:CGRectMake(_imgCodeImg.frame.size.width, 3, 0.5, _imgCodeImg.frame.size.height-6)];
        imgCodeLine.backgroundColor = HEXCOLOR(0xD6D6D6);
        [_imgCodeImg addSubview:imgCodeLine];
        
        _graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _graphicButton.frame = CGRectMake(CGRectGetMaxX(_imgCodeImg.frame)+6, 7, 26, 26);
        _graphicButton.center = CGPointMake(_graphicButton.center.x,_imgCode.center.y);
        [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateNormal];
        [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateHighlighted];
        [_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:_graphicButton];
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            n = n+HEIGHT+INSETS;
        }else {
            n = n+INSETS;
        }
#ifdef IS_TEST_VERSION
#else
#endif
        
        _code = [[UITextField alloc] initWithFrame:CGRectMake(distance, n, JX_SCREEN_WIDTH-100-distance*2, HEIGHT)];
        _code.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputMessageCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        _code.font = g_factory.font16;
        _code.delegate = self;
        _code.autocorrectionType = UITextAutocorrectionTypeNo;
        _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _code.enablesReturnKeyAutomatically = YES;
        _code.borderStyle = UITextBorderStyleNone;
        _code.returnKeyType = UIReturnKeyDone;
        _code.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_code setTextColor:[UIColor whiteColor]];

        
        UIView *codeILine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, _code.frame.size.width, 0.5)];
        codeILine.backgroundColor = HEXCOLOR(0xD6D6D6);
        [_code addSubview:codeILine];

        
        [self.tableBody addSubview:_code];
        
        _send = [UIButton buttonWithType:0];
        NSString * title = Localized(@"GET_VERIFICATION_CODE"); //@"获取验证码"

        [_send setTitle:title forState:0];
        _send.titleLabel.font = [UIFont systemFontOfSize:14];
        [_send setTitleColor:[UIColor whiteColor] forState:0];
        _send.frame = CGRectMake(JX_SCREEN_WIDTH-100-distance, n+INSETS-1, 100, 35);
        [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
        _send.backgroundColor = HEXCOLOR(0x3F94F7);
        _send.layer.masksToBounds = YES;
        _send.layer.cornerRadius = _send.frame.size.height/2;
        [self.tableBody addSubview:_send];
        
        //测试版隐藏了短信验证
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            n = n+HEIGHT+INSETS+INSETS;
        }else {
            _send.hidden = YES;
            _code.hidden = YES;
            _imgCode.hidden = YES;
            _imgCodeImg.hidden = YES;
            _graphicButton.hidden = YES;
        }
#ifdef IS_TEST_VERSION
#else
#endif
        
#ifdef IS_Skip_SMS
            // 跳过当前界面进入下个界面
            CGSize skipSize = [Localized(@"JX_NotGetSMSCode") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
            _skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-distance-skipSize.width, n, skipSize.width+4, skipSize.height)];
            [_skipBtn setTitle:Localized(@"JX_NotGetSMSCode") forState:UIControlStateNormal];
            _skipBtn.titleLabel.font = g_factory.font16;
            _skipBtn.hidden = YES;
            [_skipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_skipBtn addTarget:self action:@selector(enterNextPage) forControlEvents:UIControlEventTouchUpInside];
            [self.tableBody addSubview:_skipBtn];
#else
        
#endif
        
        //新添加的手机验证（注册）
        if ([g_config.registerInviteCode intValue] != 0) {

        }else{
            n = n+30;
        }
        
        UIButton *_btn = [UIButton buttonWithType:0];
        [_btn setTitle:@"下一步" forState:0];
        [_btn addTarget:self action:@selector(checkPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
        [_btn.titleLabel setFont:g_factory.font17];
        [_btn setBackgroundColor:HEXCOLOR(0x3F94F7)];
        _btn.frame = CGRectMake(MarginWidth, n, JX_SCREEN_WIDTH-MarginWidth*2, HEIGHT);
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = _btn.frame.size.height/2;
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.tableBody addSubview:_btn];
        n = n+HEIGHT;
        
        //注册用户
        CGSize size =[@"返回登录" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
        UIButton *registerBtn = [UIButton buttonWithType:0];
        registerBtn.frame  = CGRectMake(60, n+20, JX_SCREEN_WIDTH-60*2, HEIGHT);
        registerBtn.titleLabel.font = g_factory.font16;
        [registerBtn setTitleColor:RITLColorFromIntRBG(38, 108, 230) forState:UIControlStateNormal];
        [registerBtn setTitle:@"返回登录" forState:UIControlStateNormal];
        registerBtn.custom_acceptEventInterval = 1.0f;
        [registerBtn addTarget:self action:@selector(onGotoBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableBody addSubview:registerBtn];
        
        n = n+HEIGHT+INSETS;
        UILabel *agreeLab = [[UILabel alloc] init];
        agreeLab.font = SYSFONT(13);
        agreeLab.text = Localized(@"JX_ByRegisteringYouAgree");
        agreeLab.textColor = [UIColor blackColor];
        agreeLab.userInteractionEnabled = YES;
        [self.tableBody addSubview:agreeLab];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAgree)];
        [agreeLab addGestureRecognizer:tap1];

        UILabel*termsLab = [[UILabel alloc] init];
        termsLab.text = Localized(@"《Privacy Policy and Terms of Service》");
        termsLab.font = SYSFONT(13);
        termsLab.textColor = HEXCOLOR(0x3F94F7);
        termsLab.userInteractionEnabled = YES;
        [self.tableBody addSubview:termsLab];

        UITapGestureRecognizer *tapT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTerms)];
        [termsLab addGestureRecognizer:tapT];

        CGSize sizeA = [agreeLab.text sizeWithAttributes:@{NSFontAttributeName:agreeLab.font}];
        CGSize sizeT = [termsLab.text sizeWithAttributes:@{NSFontAttributeName:termsLab.font}];

        
        agreeLab.frame = CGRectMake((JX_SCREEN_WIDTH-sizeA.width-sizeT.width-15)/2+10, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-44, sizeA.width, sizeA.height);
        termsLab.frame = CGRectMake(CGRectGetMaxX(agreeLab.frame), JX_SCREEN_HEIGHT-JX_SCREEN_TOP-44, sizeT.width, sizeT.height);


        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAgree)];
        [_agreeImgV addGestureRecognizer:tap3];
        
        
        //测试版隐藏了短信验证
#ifdef IS_TEST_VERSION
#else
//        careFirst.hidden = YES;
//        careSecond.hidden = YES;
//        careImage.hidden = YES;
//        careTitle.hidden = YES;
#endif
//        [self.tableBody addSubview:careImage];
//        [self.tableBody addSubview:careTitle];
//        [self.tableBody addSubview:careFirst];
//        [self.tableBody addSubview:careSecond];
        
    }
    return self;
}

- (void)onGotoBack:(UIButton *)sender {
    [super actionQuit];
}

- (void)passWordRightViewClicked:(UIButton *)but{
    [_pwd resignFirstResponder];
    but.selected = !but.selected;
    _pwd.secureTextEntry = !but.selected;
}


- (void)didAgree {
    _agreeImgV.hidden = !_agreeImgV.hidden;
}

- (void)checkTerms {
    webpageVC * webVC = [webpageVC alloc];
    webVC.url = [self protocolUrl];
    webVC.isSend = NO;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
}

-(NSString *)protocolUrl{
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@pages/privacyPolicy.html", g_config.apiUrl];
    return urlStr;
}


//设置文本框只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_phone == textField) {
        return [self validateNumber:string];
    }
    return YES;
    
}
- (BOOL)validateNumber:(NSString*)number {
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        // 如果用户名注册选项开启， 则不筛选
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [number isEqualToString:filtered];
    }
    BOOL res = YES;
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i ++;
    }
    return res;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    self.bgImageview.userInteractionEnabled = YES;
    //    [self.bgImageview setImage:[UIImage imageNamed:@"登录注册_bg_logo"]];
        self.bgImageview.backgroundColor = [UIColor whiteColor];
//    self.bgImageview.backgroundColor = [UIColor blackColor];
    self.bgImageview.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.bgImageview];
    self.tableHeader.backgroundColor = [UIColor clearColor];
    self.tableBody.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
    
    
    UIImageView *topBackImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, JX_SCREEN_WIDTH, 544/2)];
    topBackImageView.image = [UIImage imageNamed:@"login_topback"];
    [self.bgImageview addSubview:topBackImageView];
    
    UIImageView *loginLogoImg = [[UIImageView alloc] initWithFrame: CGRectMake(50, 110, 160/2, 150/2)];
    loginLogoImg.image = [UIImage imageNamed:@"reg_logo"];
    [topBackImageView addSubview:loginLogoImg];
    
    UILabel *duduLabel = [[UILabel alloc] initWithFrame: CGRectMake(50+150/2, 110, 200, 70)];
    duduLabel.text = @"欢迎注册DUDU";
    duduLabel.font = [UIFont boldSystemFontOfSize:24];
    duduLabel.textColor = [UIColor whiteColor];
    duduLabel.textAlignment = NSTextAlignmentCenter;
    [topBackImageView addSubview:duduLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enterNextPage {
    _isSkipSMS = YES;
    BOOL isMobile = [self isMobileNumber:_phone.text];
    
    if ([_pwd.text length] < 6) {
        [g_App showAlert:Localized(@"JX_TurePasswordAlert")];
        return;
    }
    if (isMobile) {
        NSString *areaCode = [self getAreaCode];
        [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
    }
}
//获取当前区号
-(NSString*)getAreaCode{
    if ([self.areaLabel.text containsString:@"+"]) {
        NSRange start = [self.areaLabel.text rangeOfString:@"+"];
        NSRange end = [self.areaLabel.text rangeOfString:@")"];
        NSRange range = NSMakeRange(start.location+start.length, end.location-start.location-start.length);
        NSString *areaCode = [self.areaLabel.text substringWithRange:range];
        return areaCode;
    } else {
        return @"86";
    }
}
- (void)textFieldDidChanged:(UITextField *)textField {
    if (textField == _phone) { // 限制手机号最多只能输入11位,为了适配外国电话，将不能显示手机号位数
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            if (_phone.text.length > 11) {
                _phone.text = [_phone.text substringToIndex:10];
            }
        }else {
            if (_phone.text.length > 11) {
                _phone.text = [_phone.text substringToIndex:11];
            }
        }
    }
}


- (void)goToLoginVC {
    [self actionQuit];
}

//验证手机号码格式,无短信验证
- (void)checkPhoneNumber{
    _isSkipSMS = NO;
    BOOL isMobile = [self isMobileNumber:_phone.text];
    
    if ([_pwd.text length] < 6) {
        [g_App showAlert:Localized(@"JX_TurePasswordAlert")];
        return;
    }
    if (isMobile) {
        NSString *areaCode = [self getAreaCode];
        [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
    }
}
//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if ([_phone.text length] == 0) {
            [g_App showAlert:Localized(@"JX_InputPhone")];
            return NO;
        }
    }
#ifdef IS_TEST_VERSION
#else
#endif
    
    return YES;
}

-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];

}

-(void)getImgCodeImg{
    if([self isMobileNumber:_phone.text]){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [self getAreaCode];
        NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];

        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                _imgCodeImg.image = codeImage;
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
       
    }else{
        
    }
    
}

#pragma mark----验证短信验证码
-(void)onClick{
    if([_phone.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputPhone")];
        return;
    }
    if (!_isSkipSMS) {
        if([_code.text length]<6){
            [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            return;
        }
        
        if([_smsCode length]<6){
            [g_App showAlert:Localized(@"inputPhoneVC_NoMegCode")];
            return;
        }
        if (!([_phoneStr isEqualToString:_phone.text] && [_imgCodeStr isEqualToString:_imgCode.text] && [_smsCode isEqualToString:_code.text])) {
            
            if (![_phoneStr isEqualToString:_phone.text]) {
                [g_App showAlert:Localized(@"JX_No.Changed,Again")];
            }else if (![_imgCodeStr isEqualToString:_imgCode.text]) {
                [g_App showAlert:Localized(@"JX_ImageCodeErrorGetAgain")];
            }else if (![_smsCode isEqualToString:_code.text]) {
                [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            }
            
            
            return;
        }
        
    }


    [self.view endEditing:YES];
    if (!_isSkipSMS) {
        if([_code.text isEqualToString:_smsCode]){
            self.isSmsRegister = YES;
            [self setUserInfo];
        }
        else
            [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
    } else {
        self.isSmsRegister = NO;
        [self setUserInfo];
    }

}

- (void)setUserInfo {
    if (_agreeImgV.isHidden == YES) {
        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
        return;
    }

    JXUserObject* user = [JXUserObject sharedInstance];
    user.telephone = _phone.text;
    user.password  = [g_server getMD5String:_pwd.text];
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    PSRegisterBaseVC* vc = [PSRegisterBaseVC alloc];
    vc.isRegister = YES;
    vc.resumeId   = nil;
    vc.isSmsRegister = self.isSmsRegister;
    vc.resume     = [[resumeBaseData alloc]init];
    vc.user       = user;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [self actionQuit];
}


-(void)onTest{
    if (_agreeImgV.isHidden == YES) {
        [g_App showAlert:Localized(@"JX_NotAgreeProtocol")];
        return;
    }

    JXUserObject* user = [JXUserObject sharedInstance];
    user.telephone = _phone.text;
    user.password  = [g_server getMD5String:_pwd.text];
    NSString *areaCode = [self getAreaCode];
    user.areaCode = areaCode;
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    PSRegisterBaseVC* vc = [PSRegisterBaseVC alloc];
    vc.isRegister = YES;
    vc.resumeId   = nil;
    vc.isSmsRegister = NO;
    vc.resume     = [[resumeBaseData alloc]init];
    
    vc.user       = user;
    
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    [self actionQuit];
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_SendSMS]){
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        _send.selected = YES;
        _send.userInteractionEnabled = NO;
        _send.backgroundColor = [UIColor grayColor];
        _smsCode = [[dict objectForKey:@"code"] copy];
        
        [_send setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
        
        _phoneStr = _phone.text;
        _imgCodeStr = _imgCode.text;
    }

    
    if([aDownload.action isEqualToString:act_CheckPhone]){
        if (self.isCheckToSMS) {
            self.isCheckToSMS = NO;
            [self onSend];
            return;
        }
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
            [self onClick];
        }else {
            [self onTest];
        }
    }
}   

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if([aDownload.action isEqualToString:act_SendSMS]){
        NSString * title = Localized(@"GET_VERIFICATION_CODE"); //@"获取验证码"
        [_send setTitle:title forState:UIControlStateNormal];
        [g_App showAlert:Localized(@"JX_ImageCodeError")];
        [self getImgCodeImg];
        return hide_error;
    }
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait stop];
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
    if (_isSendFirst) {
        _isSendFirst = NO;
        _skipBtn.hidden = YES;
    }
    if (_seconds <= 30) {
        _skipBtn.hidden = NO;
    }

    if(_seconds<=0){
        but.selected = NO;
        but.userInteractionEnabled = YES;
        but.backgroundColor = g_theme.themeColor;
        [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (_timer) {
            _timer = nil;
            [sender invalidate];
        }
        _seconds = 60;
        
    }
}
//验证手机号格式
- (void)sendSMS{
    [_phone resignFirstResponder];
    [_pwd resignFirstResponder];
    [_imgCode resignFirstResponder];
    [_code resignFirstResponder];
    
    if([self isMobileNumber:_phone.text]){
        //请求验证码
        if (_imgCode.text.length < 3) {
            [g_App showAlert:Localized(@"JX_inputImgCode")];
        }else{
            //验证手机号码是否已注册
            self.isCheckToSMS = YES;
            NSString *areaCode = [self getAreaCode];
            [g_server checkPhone:_phone.text areaCode:areaCode verifyType:0 toView:self];
        }
        
    }
}

-(void)onSend{
    if (!_send.selected) {
        [_wait start:Localized(@"JX_Testing")];
        NSString *areaCode = [self getAreaCode];
        _user = [JXUserObject sharedInstance];
        _user.areaCode = areaCode;
        
        [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
        [_send setTitle:Localized(@"JX_Sending") forState:UIControlStateNormal];
        //[_wait start:Localized(@"JX_SendNow")];
        //[g_server checkPhone:_phone.text areaCode:areaCode toView:self];
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if (textField == _phone) {
            [self getImgCodeImg];
        }
    }
#ifndef IS_TEST_VERSION
#endif
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    JXTelAreaListVC *telAreaListVC = [[JXTelAreaListVC alloc] init];
    telAreaListVC.telAreaDelegate = self;
    telAreaListVC.didSelect = @selector(didSelectTelArea:);
//    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}
- (void)didSelectTelArea:(NSDictionary *)areaCode{
    NSString *currentLocaleLanguageCode= @"en";
    NSArray *languages = [NSLocale preferredLanguages];
            if (languages.count>0) {
                currentLocaleLanguageCode = languages.firstObject;
                if ([currentLocaleLanguageCode hasPrefix:@"en"]) {
                    currentLocaleLanguageCode = @"en";
                }
                else if ([currentLocaleLanguageCode hasPrefix:@"zh"]) {
                    currentLocaleLanguageCode = @"zh";
                }
                else {
                    currentLocaleLanguageCode = @"en";
                }
            }
            else {
                currentLocaleLanguageCode = @"en";
            }
    if ([currentLocaleLanguageCode hasPrefix:@"zh"]) {
        self.areaLabel.text = [NSString stringWithFormat:@"%@(+%@)",areaCode[@"country"],areaCode[@"prefix"]];
    }else{
        self.areaLabel.text = [NSString stringWithFormat:@"%@(+%@)",areaCode[@"enName"],areaCode[@"prefix"]];
    }
    [_areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
    [self resetBtnEdgeInsets:_areaCodeBtn];
}

- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}

- (void)hideKeyBoardToView {
    [self.view endEditing:YES];
}


@end
