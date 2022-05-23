//
//  JXAVCallViewController.h
//  shiku_im
//
//  Created by p on 2017/12/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
//#import <AgoraAudioKit/AgoraRtcEngineKit.h>
#import "AgoraModel.h"
//#import <JitsiMeet/JitsiMeet.h>

@interface JXAVCallViewController : UIViewController{
    UIButton* _buttonHangup;
    UIButton* _buttonAccept;
}

@property (nonatomic, strong) JXAVCallViewController *pSelf;
@property (nonatomic, copy) NSString *roomNum;
@property (nonatomic, assign) BOOL isAudio;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *toUserName;
@property (nonatomic, copy) NSString *meetUrl;
@property (strong, nonatomic)AgoraModel *model;
@end
