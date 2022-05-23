//
//  myViewController.m
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PSMyViewController.h"
#import "JXImageView.h"
#import "JXLabel.h"
#import "AppDelegate.h"
#import "JXServer.h"
#import "JXConnection.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "JXFriendViewController.h"
#import "ImageResize.h"
#import "userWeiboVC.h"
#import "myMediaVC.h"
#import "loginVC.h"
#import "JXNewFriendViewController.h"
#import "PSRegisterBaseVC.h"
#import "photosViewController.h"
#import "JXSettingVC.h"
#import "PSUpdateUserVC.h"
#import "OrganizTreeViewController.h"
#import "JXCourseListVC.h"
#import "JXMyMoneyViewController.h"
#import "JXNearVC.h"
#import "JXSelFriendVC.h"
#import "JXSelectFriendsVC.h"
#ifdef Meeting_Version
#import "JXAVCallViewController.h"
#endif

#ifdef Live_Version
#import "JXLiveViewController.h"
#endif

#import "JXFriendViewController.h"
#import "JXGroupViewController.h"
#import "UIImage+Color.h"
#import "JXQRCodeViewController.h"
#define HEIGHT 56
#define MY_INSET  0  // 每行左右间隙
#define TOP_ADD_HEIGHT  400  // 顶部添加的高度，防止下拉顶部空白

#import "JXBlogRemind.h"
#import "JXBlogRemindVC.h"
#import "JXMyShareVC.h"
#import "JXChatViewController.h"
#import "JXAddBankCardViewController.h"
@implementation PSMyViewController
{
    UILabel *lblSmrzStaStatus;
    UILabel *versionLabel;
    BOOL isgetState;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.isRefresh = NO;
//        self.title = @"设置";
        NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        self.heightHeader = -statusHeight;
        self.heightFooter = JX_SCREEN_BOTTOM;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
        self.view.backgroundColor = HEXCOLOR(0xf0eff4);
    

        int h = 0;
        int w=JX_SCREEN_WIDTH;
        
        float marginHei = 8;
        
        int H = 86;
        
//        self.heightHeader = JX_SCREEN_TOP;
//        [self createHeadAndFoot];
        
        
        
        //添加灰色的线
//        UIView *grayLine = [UIView new];
//        grayLine.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 10);
//        grayLine.backgroundColor = HEXCOLOR(0xf0eff4);
//        [self.tableBody addSubview:grayLine];

        JXImageView* iv;
        iv = [self createHeadButtonclick:@selector(onResume)];
        _topImageVeiw = iv;
//        CGFloat height = THE_DEVICE_HAVE_HEAD ? 55 : 75;
//        if (THESIMPLESTYLE) {
//            iv.frame = CGRectMake(0, h-TOP_ADD_HEIGHT, w, 266+TOP_ADD_HEIGHT-H+55);
//            h+=iv.frame.size.height-TOP_ADD_HEIGHT;
//        }else {
//            iv.frame = CGRectMake(0, h-TOP_ADD_HEIGHT, w, 266 + TOP_ADD_HEIGHT - H);
//            NSLog(@"header frame is %@", NSStringFromCGRect(iv.frame));
//            h+=iv.frame.size.height-TOP_ADD_HEIGHT+ height;
//        }
        
        
        // lewis 头部调整， 273 变为 140
//        iv.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 273+statusHeight);
        iv.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 140+statusHeight);
        h = CGRectGetMaxY(iv.frame);

        h += marginHei;
        if ([g_App. isShowRedPacket intValue] == 1) {
            iv = [self createButton:Localized(@"JXMoney_myPocket") drawTop:NO drawBottom:YES icon: @"balance_recharge" click:@selector(onRecharge)];
            iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//            _moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-135,11,100-MY_INSET,30)];
//            _moneyLabel.textAlignment = NSTextAlignmentRight;
//            _moneyLabel.userInteractionEnabled = NO;
//            _moneyLabel.font = g_factory.font15;
//            [iv addSubview:_moneyLabel];
            
            h+=iv.frame.size.height;
            
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(iv.frame),JX_SCREEN_WIDTH,0.3)];
            line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
            [self.tableBody addSubview:line];
        }
        
        
//        iv = [self createButton:Localized(@"JX_MyDynamics") drawTop:NO drawBottom:YES icon: @"my_space" click:@selector(onMyBlog)];

        iv = [self createButton:Localized(@"我的图片") drawTop:NO drawBottom:YES icon: @"my_space" click:@selector(onMyBlog)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height;
        
//        iv = [self createButton:Localized(@"JX_MyCollection") drawTop:NO drawBottom:YES icon: @"collection_me" click:@selector(onMyFavorite)];
//        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//        h+=iv.frame.size.height;
        
        // lewis
        iv = [self createButton:Localized(@"与我相关") drawTop:NO drawBottom:YES icon: @"my_yuwoxiangguan" click:@selector(onMyRelate)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height;
        // lewis
//        iv = [self createButton:@"推广中心" drawTop:NO drawBottom:YES icon: @"my_tuiguang" click:@selector(onMyShare)];
//        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//        h+=iv.frame.size.height;
//         lewis
        iv = [self createButton:Localized(@"我的客服") drawTop:NO drawBottom:YES icon: @"my_kefu" click:@selector(onService)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
        h+=iv.frame.size.height ;
        
//        iv = [self createButton:Localized(@"实名认证") drawTop:NO drawBottom:YES icon:@"my_smrz" click:@selector(smrzMethod)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        lblSmrzStaStatus = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET-200, iv.frame.origin.y, 200, iv.frame.size.height)];
//        lblSmrzStaStatus.font = [UIFont systemFontOfSize:14];
//        [lblSmrzStaStatus setTextColor:[UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1]];
//        lblSmrzStaStatus.text = Localized(@"未实名");
//        lblSmrzStaStatus.textAlignment = NSTextAlignmentRight;
//        [self.tableBody addSubview:lblSmrzStaStatus];
//        h+=iv.frame.size.height+ marginHei;
        
//        iv = [self createButton:Localized(@"JX_MyLecture") drawTop:NO drawBottom:YES icon: @"my_lecture" click:@selector(onCourse)];
//        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//        h+=iv.frame.size.height + marginHei;
        
//        iv = [self createButton:Localized(@"JXNearVC_NearHere") drawTop:NO drawBottom:YES icon:@"nearby_normal" click:@selector(onNear)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;

//#ifdef Live_Version
//        iv = [self createButton:Localized(@"OrganizVC_Organiz") drawTop:NO drawBottom:YES icon:@"my_organizBook" click:@selector(onOrganiz)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
//#endif
        
        
//        iv = [self createButton:@"收藏职位" drawTop:NO drawBottom:YES icon:@"set_collect" click:@selector(onMoney)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        BOOL isShowLine = NO;
//#ifdef IS_SHOW_MENU
//#else
//#ifdef Meeting_Version
//        isShowLine = YES;
//        iv = [self createButton:Localized(@"JXSettingVC_VideoMeeting") drawTop:isShowLine drawBottom:YES icon: @"videomeeting" click:@selector(onMeeting)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
//        isShowLine = NO;
//#else
//        isShowLine = YES;
//#endif
        
//#ifdef Live_Version
//        if ([g_App.isShowRedPacket intValue] == 1 ) {
//            iv = [self createButton:Localized(@"JX_LiveDemonstration") drawTop:isShowLine drawBottom:YES icon: @"videoshow" click:@selector(onLive)];
//            iv.frame = CGRectMake(0,h, w, HEIGHT);
//            h+=iv.frame.size.height + marginHei;
//        }
//        isShowLine = YES;
//#else
//        isShowLine = NO;
//#endif

//#endif

        
        iv = [self createButton:Localized(@"JX_Settings") drawTop:YES drawBottom:YES icon: @"set_up" click:@selector(onSetting)];
        iv.frame = CGRectMake(MY_INSET,h, w-MY_INSET*2, HEIGHT);
//        h+=iv.frame.size.height;
        
        if ((h + HEIGHT + 20) > self.tableBody.frame.size.height) {
            self.tableBody.contentSize = CGSizeMake(self_width, h + HEIGHT + 20);
        }
        
        [g_notify addObserver:self selector:@selector(doRefresh:) name:kUpdateUserNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(updateUserInfo:) name:kXMPPMessageUpadteUserInfoNotification object:nil];
        //获取用户余额
        [g_server getUserMoenyToView:self];
        isgetState = YES;
        [g_server getUser:MY_USER_ID toView:self];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getfourElementsMethod) name:@"getfourElements" object:nil];
        
        
        versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, h + 100, JX_SCREEN_WIDTH, iv.frame.size.height)];
        versionLabel.font = [UIFont systemFontOfSize:14];
        [versionLabel setTextColor:[UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1]];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        versionLabel.text = [NSString stringWithFormat:@"Version:%@",app_Version];
        versionLabel.textAlignment = NSTextAlignmentCenter;
        [self.tableBody addSubview:versionLabel];
        
    }
    return self;
}
-(void)getfourElementsMethod{
    isgetState = YES;
    [g_server getUser:MY_USER_ID toView:self];
}
- (void)updateUserInfo:(NSNotification *)noti {
    self.isXmppUpdate = YES;
    isgetState = NO;
    [g_server getUser:g_server.myself.userId toView:self];
}

-(void)dealloc{
    NSLog(@"PSMyViewController.dealloc");
    [g_notify removeObserver:self name:kUpdateUserNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageUpadteUserInfoNotification object:nil];
//    [_image release];
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *friends = [[JXUserObject sharedInstance] fetchAllUserFromLocal];
    _friendLabel.text = [NSString stringWithFormat:@"%ld",friends.count];
    NSArray *groups = [[JXUserObject sharedInstance] fetchAllRoomsFromLocal];
    _groupLabel.text = [NSString stringWithFormat:@"%ld",groups.count];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isRefresh) {
        self.isRefresh = NO;
    }else{
        [super viewDidAppear:animated];
        [self doRefresh:nil];
    }

}

-(void)doRefresh:(NSNotification *)notifacation{
    _head.image = nil;
    [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:_head];
    //获取用户余额
//    [g_server getUserMoenyToView:self];
    _userName.text = g_server.myself.userNickname;
    _userDesc.text = g_server.myself.telephone;
//    _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
}

//-(void)refreshUserDetail{
//    _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//服务端返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
        [_wait hide];
    if( [aDownload.action isEqualToString:act_resumeList] ){
    }
    if( [aDownload.action isEqualToString:act_UserGet] ){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        g_server.myself.userNickname = user.userNickname;
        NSRange range = [user.telephone rangeOfString:@"86"];
        if (range.location != NSNotFound) {
            g_server.myself.telephone = [user.telephone substringFromIndex:range.location + range.length];
        }
        
        if (self.isXmppUpdate) {
            self.isXmppUpdate = NO;
            _userName.text = user.userNickname;
            [g_server delHeadImage:g_server.myself.userId];
            [g_server getHeadImageSmall:g_server.myself.userId userName:g_server.myself.userNickname imageView:_head];
            return;
        }
        
        if (!isgetState) {
            PSUpdateUserVC* vc = [PSUpdateUserVC alloc];
            vc.headImage = [_head.image copy];
            vc.user = user;
            
            //JTFX
    //        [user release];
            
            vc = [vc init];
        
            [g_navigation pushViewController:vc animated:YES];
        }
       
        if ([user.fourElements intValue]==1) {
            lblSmrzStaStatus.text = Localized(@"已实名");
        }else{
            lblSmrzStaStatus.text = Localized(@"未实名");
        }
    }
    if ([aDownload.action isEqualToString:act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        _moneyLabel.text = [NSString stringWithFormat:@"%.2f%@",g_App.myMoney,Localized(@"JX_ChinaMoney")];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
//    [_wait start];
}

-(void)actionClear{
    [_wait start:Localized(@"PSMyViewController_Clearing") delay:100];
}

#ifdef Live_Version
// 直播
- (void)onLive {
    JXLiveViewController *vc = [[JXLiveViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}
#endif

#ifdef Meeting_Version
// 视频会议
- (void)onMeeting {
    if(g_xmpp.isLogined != 1){
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    NSString *str1;
    NSString *str2;

    str1 = Localized(@"JXSettingVC_VideoMeeting");
    str2 = Localized(@"JX_Meeting");

    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[@"meeting_tel",@"meeting_video"] names:@[str2,str1]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        [self onGroupAudioMeeting:nil];
    }else if(index == 1){
        [self onGroupVideoMeeting:nil];
    }
}
-(void)onGroupAudioMeeting:(JXMessageObject*)msg{

    self.isAudioMeeting = YES;
    [self onInvite];
    //    [g_meeting startAudioMeeting:no roomJid:s];
}

-(void)onGroupVideoMeeting:(JXMessageObject*)msg{

    self.isAudioMeeting = NO;
    [self onInvite];
    //    [g_meeting startVideoMeeting:no roomJid:s];
}
-(void)onInvite{

    
    NSMutableSet* p = [[NSMutableSet alloc]init];
    
    JXSelectFriendsVC* vc = [JXSelectFriendsVC alloc];
    vc.isNewRoom = NO;
    vc.isShowMySelf = NO;
    vc.type = JXSelUserTypeSelFriends;
//    vc.room = _room;
    vc.existSet = p;
    vc.delegate = self;
    vc.didSelect = @selector(meetingAddMember:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)meetingAddMember:(JXSelectFriendsVC*)vc{
    int type;
    if (self.isAudioMeeting) {
        type = kWCMessageTypeAudioMeetingInvite;
    }else {
        type = kWCMessageTypeVideoMeetingInvite;
    }
    for(NSNumber* n in vc.set){
        JXUserObject *user;
        if (vc.seekTextField.text.length > 0) {
            user = vc.searchArray[[n intValue] % 1000];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 1000] objectAtIndex:[n intValue] % 1000];
        }
        NSString* s = [NSString stringWithFormat:@"%@",user.userId];
        [g_meeting sendMeetingInvite:s toUserName:user.userNickname roomJid:MY_USER_ID callId:nil type:type];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_meeting.isMeeting) {
            return;
        }
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.roomNum = MY_USER_ID;
        avVC.isAudio = self.isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = MY_USER_NAME;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        
    });
    
}
#endif


-(void)onMyBlog{
    userWeiboVC* vc = [userWeiboVC alloc];
    vc.user = g_myself;
    vc.isGotoBack = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];

}
-(void)onNear{
    JXNearVC * nearVc = [[JXNearVC alloc] init];
//    [g_window addSubview:nearVc.view];
    [g_navigation pushViewController:nearVc animated:YES];
}
-(void)onFriend{
    JXFriendViewController* vc = [[JXFriendViewController alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onResume{
    isgetState = NO;
    [g_server getUser:MY_USER_ID toView:self];
}

-(void)onSpace{
//    mySpaceViewController* vc = [[mySpaceViewController alloc]init];
//    [g_window addSubview:vc.view];
}

-(void)onVideo{
    myMediaVC* vc = [[myMediaVC alloc] init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
-(void)onMyFavorite{
    WeiboViewControlle * collection = [[WeiboViewControlle alloc] initCollection];
    
//    [g_window addSubview:collection.view];
    [g_navigation pushViewController:collection animated:YES];
}

// lewis
-(void)onMyRelate{
    NSMutableArray *remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
    vc.remindArray = remindArray;
    vc.isShowAll = YES;
    //        [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

// lewis
-(void)onMyShare{
    JXMyShareVC *vc = [[JXMyShareVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// lewis
-(void)onService{
    JXUserObject *user = [[JXUserObject alloc] init];
    user.userId = @"10000";
    user.userNickname = Localized(@"我的客服");
    user.status = [NSNumber numberWithInt:8];
    user.type = [NSNumber numberWithInt:1];
    user.userType = [NSNumber numberWithInt:2];
    
    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = user.userNickname;
    sendView.rowIndex = 0;
    sendView.lastMsg = nil;
    sendView.chatPerson = user;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
        [g_navigation pushViewController:sendView animated:YES];
}

- (void)onCourse {
    JXCourseListVC *vc = [[JXCourseListVC alloc] init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onRecharge{
    JXMyMoneyViewController * moneyVC = [[JXMyMoneyViewController alloc] init];
//    [g_window addSubview:moneyVC.view];
    [g_navigation pushViewController:moneyVC animated:YES];
    
}

-(void)onOrganiz{
    OrganizTreeViewController * organizVC = [[OrganizTreeViewController alloc] init];
//    [g_window addSubview:organizVC.view];
    [g_navigation pushViewController:organizVC animated:YES];
}
-(void)onMyLove{
    
}

-(void)onMoney{
}

-(void)onSetting{
    JXSettingVC* vc = [[JXSettingVC alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
//-(void)showUserQRCode{
//    JXQRCodeViewController * qrVC = [[JXQRCodeViewController alloc] init];
//    qrVC.type = QRUserType;
//    qrVC.userId = user.userId;
//    qrVC.account = user.account;
//    qrVC.nickName = user.userNickname;
////    [g_window addSubview:qrVC.view];
//    [g_navigation pushViewController:qrVC animated:YES];
//}
-(void)showUserQRCode{
    JXQRCodeViewController * qrVC = [[JXQRCodeViewController alloc] init];
    qrVC.type = QRUserType;
    qrVC.userId = g_server.myself.userId;
    qrVC.account = g_server.myself.account;
    qrVC.nickName = g_server.myself.userNickname;
//    [g_window addSubview:qrVC.view];
    [g_navigation pushViewController:qrVC animated:YES];
}
//-(JXImageView*)createHeadButtonclick:(SEL)click{
//
//     NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//
//    JXImageView* btn = [[JXImageView alloc] init];
//    btn.backgroundColor = [UIColor whiteColor];
//    btn.userInteractionEnabled = YES;
//    btn.didTouch = click;
//    btn.delegate = self;
//    [self.tableBody addSubview:btn];
//    UIColor *color;
//    if (THESIMPLESTYLE) {
//        color = [UIColor whiteColor];
//    }else {
//        color = THEMECOLOR;
//    }
//
//    color = THEMECOLOR;
//    btn.backgroundColor = HEXCOLOR(0xf0eff4);;
////    [self setupView:btn colors:@[(__bridge id)color.CGColor,(__bridge id)[color colorWithAlphaComponent:0.5].CGColor]];
//
//    // 重设title的frame
//
//    UIView *whiteBgView = [UIView new];
//    whiteBgView.backgroundColor = [UIColor whiteColor];
//    whiteBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 273+statusHeight);
//    [btn addSubview:whiteBgView];
//
//
//    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 180+statusHeight)];
//    backImgView.image = [UIImage imageNamed:@"myback_icon"];
//    [whiteBgView addSubview:backImgView];
//
//    _head = [[JXImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-100)*0.5, 100+statusHeight, 100, 100)];
//    _head.layer.cornerRadius = _head.height*0.5;
//    _head.layer.borderColor = [UIColor whiteColor].CGColor;
//    _head.layer.borderWidth = 2;
//    _head.layer.masksToBounds = YES;
//    [whiteBgView addSubview:_head];
//
//
////    self.tableBody.scrollEnabled = NO;
//
//
//    //名字Label
//    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(0, _head.bottom+13, JX_SCREEN_WIDTH, 20)];
//    p.font = SYSFONT(18);
//    p.textAlignment = NSTextAlignmentCenter;
//    p.text = MY_USER_NAME;
//    p.textColor = HEXCOLOR(0x000000);
//    p.backgroundColor = [UIColor clearColor];
//    [whiteBgView addSubview:p];
//    _userName = p;
//
//    //电话Label
//    p = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(p.frame), CGRectGetMaxY(p.frame)+13, JX_SCREEN_WIDTH, 16)];
//    p.font = SYSFONT(13);
//    p.textAlignment = NSTextAlignmentCenter;
//    p.text = g_server.myself.telephone;
//    p.textColor = HEXCOLOR(0x9c9c9c);
//    p.backgroundColor = [UIColor clearColor];
//    [whiteBgView addSubview:p];
//    _userDesc = p;
//
//
//    UIButton *qrBtn = [UIButton buttonWithType:0];
//    [qrBtn setImage:[UIImage imageNamed:@"my_qrcode"] forState:0];
//    qrBtn.frame = CGRectMake(JX_SCREEN_WIDTH-40-20, statusHeight+20, 40, 40);
//    [qrBtn addTarget:self action:@selector(showUserQRCode) forControlEvents:UIControlEventTouchUpInside];
//    [whiteBgView addSubview:qrBtn];
//
//    return btn;
//}

// lewis 修改位置
-(JXImageView*)createHeadButtonclick:(SEL)click{
    
     NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [self.tableBody addSubview:btn];
    UIColor *color;
    if (THESIMPLESTYLE) {
        color = [UIColor whiteColor];
    }else {
        color = THEMECOLOR;
    }
    
    color = THEMECOLOR;
    btn.backgroundColor = HEXCOLOR(0xf0eff4);;
//    [self setupView:btn colors:@[(__bridge id)color.CGColor,(__bridge id)[color colorWithAlphaComponent:0.5].CGColor]];

    // 重设title的frame
    
    UIView *whiteBgView = [UIView new];
    whiteBgView.backgroundColor = [UIColor whiteColor];
    whiteBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 140+statusHeight);
    [btn addSubview:whiteBgView];
    
    
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 200+statusHeight)];
    backImgView.image = [UIImage imageNamed:@"myback_icon"];
    [whiteBgView addSubview:backImgView];
    backImgView.hidden = YES;
    
    _head = [[JXImageView alloc]initWithFrame:CGRectMake(20, 30+statusHeight, 100, 100)];
    _head.layer.cornerRadius = 3.0f;//lewis _head.height*0.5;
    _head.layer.borderColor = [UIColor whiteColor].CGColor;
    _head.layer.borderWidth = 2;
    _head.layer.masksToBounds = YES;
    [whiteBgView addSubview:_head];
    
    
//    self.tableBody.scrollEnabled = NO;
    

    //名字Label
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(_head.right+20, _head.top+30, JX_SCREEN_WIDTH-100, 22)];
    p.font = SYSFONT(20);
    p.textAlignment = NSTextAlignmentLeft;
    p.text = MY_USER_NAME;
    p.textColor = HEXCOLOR(0x000000);
    p.backgroundColor = [UIColor clearColor];
    [whiteBgView addSubview:p];
    _userName = p;
    
    // 描述
    p = [[UILabel alloc]initWithFrame:CGRectMake(_head.right+20, _userName.bottom+10, JX_SCREEN_WIDTH-100, 16)];
    p.font = SYSFONT(13);
    p.textAlignment = NSTextAlignmentLeft;
    p.text = Localized(@"JX_BaseInfo");
    p.textColor = HEXCOLOR(0x000000);//HEXCOLOR(0x9c9c9c);
    p.backgroundColor = [UIColor clearColor];
    [whiteBgView addSubview:p];
    _userDesc = p;
    
    // 箭头
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, _head.top+40, 20, 20)];
    iv.image = [UIImage imageNamed:@"set_list_next"];
    [btn addSubview:iv];
    
    //电话Label
    p = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(p.frame), CGRectGetMaxY(p.frame)+13, JX_SCREEN_WIDTH, 16)];
    p.font = SYSFONT(13);
    p.textAlignment = NSTextAlignmentCenter;
    p.text = g_server.myself.telephone;
    p.textColor = HEXCOLOR(0x9c9c9c);
    p.backgroundColor = [UIColor clearColor];
    [whiteBgView addSubview:p];
    _userDesc = p;
    _userDesc.hidden = YES;

   
    UIButton *qrBtn = [UIButton buttonWithType:0];
    [qrBtn setImage:[UIImage imageNamed:@"my_qrcode"] forState:0];
    qrBtn.frame = CGRectMake(JX_SCREEN_WIDTH-40-20, statusHeight+10, 40, 40);
    [qrBtn addTarget:self action:@selector(showUserQRCode) forControlEvents:UIControlEventTouchUpInside];
    [whiteBgView addSubview:qrBtn];
    
    qrBtn.hidden = YES;

    return btn;
}

- (void)onColleagues:(UITapGestureRecognizer *)tap {
    // 防止好友、群组同时调用
    if (_isSelected)
        return;
    _isSelected = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isSelected = NO;
    });
    switch (tap.view.tag) {
        case 0:{
            JXFriendViewController *friendVC = [JXFriendViewController alloc];
            friendVC.isMyGoIn = YES;
            friendVC = [friendVC  init];
            [g_navigation pushViewController:friendVC animated:YES];
        }
            break;
        case 1:{
            JXGroupViewController *groupVC = [[JXGroupViewController alloc] init];
            [g_navigation pushViewController:groupVC animated:YES];
        }
            break;
        default:
            break;
    }

}

- (UIButton *)createViewWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)icon index:(CGFloat)index showLine:(BOOL)isShow{
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
    if (index == 0) {
        _friendLabel = label;
    }else {
        _groupLabel = label;
    }
    if (isShow) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width-.5, (view.frame.size.height-24)/2, .5, 24)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [view addSubview:line];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onColleagues:)];
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+8, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
//    p.delegate = self;
//    p.didTouch = click;
    [btn addSubview:p];

    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT-20)/2, 21, 21)];
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
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, 16, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        
    }
    return btn;
}

//内存泄漏，为啥？
-(void)onHeadImage{
    [g_server delHeadImage:g_myself.userId];
    
    JXImageScrollVC * imageVC = [[JXImageScrollVC alloc]init];
    
    imageVC.imageSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH);

    
    imageVC.iv = [[JXImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
    
    imageVC.iv.backgroundColor = [UIColor redColor];
    
    imageVC.iv.center = imageVC.view.center;
    
    [g_server getHeadImageLarge:g_myself.userId userName:g_myself.userNickname imageView:imageVC.iv];
    
    [self addTransition:imageVC];
    
    [self presentViewController:imageVC animated:YES completion:^{
        self.isRefresh = YES;
    
    }];
    
//    [imageVC release];
    
    

}

- (void)setupView:(UIView *)view colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 266+TOP_ADD_HEIGHT-86);  // 设置显示的frame
    gradientLayer.colors = colors;  // 设置渐变颜色
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    [view.layer addSublayer:gradientLayer];
}


//添加VC转场动画
- (void) addTransition:(JXImageScrollVC *) siv
{
    self.scaleTransition = [[DMScaleTransition alloc]init];
    [siv setTransitioningDelegate:self.scaleTransition];
    
}

//-(void)onSearch{
//    JXNearVC* vc = [[JXNearVC alloc] init];
//    [g_window addSubview:vc.view];
//    [vc onSearch];
//}
//实名认证
-(void)smrzMethod{
    if (![lblSmrzStaStatus.text isEqualToString:Localized(@"已实名")]) {
        JXAddBankCardViewController * addBankCardVC = [[JXAddBankCardViewController alloc] init];
        [g_navigation pushViewController:addBankCardVC animated:YES];
    }
}
@end
