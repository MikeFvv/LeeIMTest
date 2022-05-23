//
//  XL_Header.h
//  shiku_im
//
//  Created by 张艺露 on 2021/2/28.
//  Copyright © 2021 Reese. All rights reserved.
//

#ifndef XL_Header_h
#define XL_Header_h

#define XL_APP_NAME                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]


/// ooo<<<
// 65.52.183.104
// 20.24.64.55   GGE
// 20.24.80.134  一起团
// 118.107.44.103  ？

//接口前缀      self.apiUrl = @"http://192.168.0.103:8092/";
#define XL_API_URL                      @"http://20.187.93.69:8092/"

//AppDelegate·
//config.backUrl = @"http://imapi.suliao6688.com/";
//config.apiUrl = @"http://imapi.suliao6688.com/";
//config.uploadUrl = @"http://imapi.suliao6688.com/";
//config.downloadAvatarUrl = @"http://imapi.suliao6688.com/";
//config.downloadUrl = @"http://imapi.suliao6688.com/";
//config.XMPPHost = @"http://imapi.suliao6688.com";
//config.XMPPDomain = @"http://imapi.suliao6688.com";
#define XL_API_BACK_URL                 @"http://20.187.93.69:8092/"
#define XL_API_API_URL                  @"http://20.187.93.69:8092/"
#define XL_API_UPLOAD_URL               @"http://20.187.93.69:8088/"
#define XL_API_DOWNLOAD_AVATAR_URL      @"http://20.187.93.69:8089/"
#define XL_API_DOWNLOAD_URL             @"http://20.187.93.69:8089/"
#define XL_API_XMPP_HOST                @"http://20.187.93.69"
#define XL_API_XMPP_DOMAIN              @"http://20.187.93.69"
//是否永久禁言    1是  2否
#define XL_PermanentlyBanned            @YES

//显示群二维码 1是  2否
#define XL_Show_Room_Qrcode             2

//显示短信验证码 1是  2否
#define XL_Show_MsgCode                 2

//隐藏短信登录 1是  2否
#define XL_Hidden_MsgLoging             1

//中间活动tabbar title
//#define XL_Tabbar_Middle                @"比分"
#define XL_Tabbar_Middle                @""

//隐藏除入群外，其他消息 1是  2否
#define XL_Hidden_System_Message        1

//需要隐藏的系统消息关键字
#define XL_Hidden_System_Message_List   @[@"撤回了一条消息",@"撤回了一條消息",@"移出群聊",@"移出群聊"]
//#define XL_Hidden_System_Message_List   @[@"撤回了一条消息",@"撤回了一條消息",\
//                                          @"解散了此群",@"解散了此群",\
//                                          @"进入群组",@"進入群組",\
//                                          @"邀请成员",@"邀請成員",\
//                                          @"移出群聊",@"移出群聊",\
//                                          @"取消管理员",@"取消管理員",\
//                                          @"已成为新群主",@"已成為新群主",\
//                                          @"改为公开群组",@"改為公開群組",\
//                                          @"改为私密群组",@"改為私密群組",\
//                                          @"消息已读人数模式",@"消息已讀人數模式",\
//                                          @"进群验证",@"進群驗證",\
//                                          @"查看群成员功能",@"查看群成員功能",\
//                                          @"普通成员私聊功能",@"普通成員私聊功能",\
//                                          @"允许成员邀请好友",@"允許成員邀請好友",\
//                                          @"成员上传群共享文件",@"成員上傳群共享文件",\
//                                          @"允许成员召开会议",@"允許成員召開會議",\
//                                          @"允许成员开启讲课",@"允許成員開啟講課",\
//                                          @"上传了群文件",@"上傳了群文件"]
//是否隐藏此消息
#define isHiddenMsg(msg) [XL_Tool isHiddenMsg:msg]

#endif /* XL_Header_h */

