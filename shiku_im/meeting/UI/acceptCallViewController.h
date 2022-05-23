//
//  acceptCallViewController.h
//  shiku_im
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"
#import "AgoraModel.h"

@class JXAudioPlayer;

@interface acceptCallViewController : admobViewController{
    UIButton* _buttonHangup;
    UIButton* _buttonAccept;
    JXAudioPlayer* _player;
}
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, copy) NSString * toUserId;
@property (nonatomic, copy) NSString * toUserName;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString * roomNum;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (copy, nonatomic)NSString *meetUrl;
@property (strong, nonatomic)AgoraModel *model;
@end
