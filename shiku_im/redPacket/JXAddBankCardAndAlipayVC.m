//
//  JXAddBankCardAndAlipayVC.m
//  shiku_im
//
//  Created by aaa on 2019/12/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXAddBankCardAndAlipayVC.h"
#import "JXAddBankCardViewController.h"

@interface JXBankCardInfoView : UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bankLabel;
@property (nonatomic, strong) UILabel *bankCradNumLabel;
@property (nonatomic, strong) UILabel *bankAddressLabel;


@end

@implementation JXBankCardInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        UIView *bgView = [UIView new];
        bgView.frame = CGRectMake(50, (JX_SCREEN_HEIGHT - 270) / 2, JX_SCREEN_WIDTH - 100, 270);
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 6;
        [self addSubview:bgView];
        
        CGFloat h = 30;
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.frame = CGRectMake(20, h, 200, 30);
        [bgView addSubview:_nameLabel];
        
         h += 60;
        _bankLabel = [UILabel new];
        _bankLabel.font = [UIFont systemFontOfSize:18];
        _bankLabel.textColor = [UIColor blackColor];
        _bankLabel.frame = CGRectMake(20, h, 200, 30);
        [bgView addSubview:_bankLabel];
        
         h += 60;
         _bankCradNumLabel = [UILabel new];
        _bankCradNumLabel.font = [UIFont systemFontOfSize:18];
        _bankCradNumLabel.textColor = [UIColor blackColor];
        _bankCradNumLabel.frame = CGRectMake(20, h, 200, 30);
        [bgView addSubview:_bankCradNumLabel];
        
        h += 60;
        _bankAddressLabel = [UILabel new];
        _bankAddressLabel.font = [UIFont systemFontOfSize:18];
        _bankAddressLabel.textColor = [UIColor blackColor];
        _bankAddressLabel.frame = CGRectMake(20, h, 200, 30);
        [bgView addSubview:_bankAddressLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)dismissView{
    
    [self removeFromSuperview];
}

+ (void)showConfirmViewWithBankName:(NSString *)bankName bankCard:(NSString *)bankCard bankAddress:(NSString *)bankAddress userName:(NSString *)userName {
    
      JXBankCardInfoView *confirmView = [[JXBankCardInfoView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    
    confirmView.nameLabel.text = [NSString stringWithFormat:@"持卡人:%@", userName];
    confirmView.bankLabel.text = [NSString stringWithFormat:@"银行类型:%@", bankName];
    confirmView.bankCradNumLabel.text = [NSString stringWithFormat:@"卡号:%@", bankCard];
    confirmView.bankAddressLabel.text = [NSString stringWithFormat:@"开户地址:%@", bankAddress];
    [g_window addSubview:confirmView];

}


@end

@interface JXAddBankCardAndAlipayVC ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) NSInteger deleteIndex;
@property (nonatomic, strong) NSDictionary *bankImageDictionary;


@end

@implementation JXAddBankCardAndAlipayVC

- (instancetype)init{
    
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _array = [NSMutableArray array];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressAction:)];
    lpgr.minimumPressDuration = 1.0; //seconds  设置长按多长事件触发长按事件
    [self.tableView addGestureRecognizer:lpgr];//把该事件加载到tableview对象上
    
    [self createHeadAndFoot];

    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    self.title = @"添加银行卡/支付宝";
        
    [self addBankCrad];
    
    NSDictionary *dict = @{@"100" : @"play_treasure",
                           @"101" : @"ic_cardbg_boc",
                           @"102" : @"ic_cardbg_ccb",
                           @"103" : @"ic_cardbg_icbc",
                           @"104" : @"ic_cardbg_abc",
                           @"105" : @"ic_cardbg_comm",
                           @"106" : @"ic_cardbg_psbc",
                           @"107" : @"ic_cardbg_gf",
                           @"108" : @"ic_cardbg_bh",
                           @"109" : @"ic_cardbg_hf",
                           @"110" : @"ic_cardbg_hx",
                           @"111" : @"ic_cardbg_sh",
                           @"112" : @"ic_cardbg_wz",
                           @"113" : @"ic_cardbg_xy",
                           @"114" : @"ic_cardbg_zs",
                           @"115" : @"ic_cardbg_zss",
                           @"116" : @"ic_cardbg_gd",
                           @"117" : @"ic_cardbg_ms",
                           @"118" : @"ic_cardbg_zx",
                           @"119" : @"ic_cardbg_bj",
    };
    
    self.bankImageDictionary = dict;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //先去请求银行卡列表
    long time = (long)[[NSDate date] timeIntervalSince1970];
    NSString *secret = [self getSecretWithtime:time];
    
    // 开始网络请求
    [g_server getBindBankCardListWithSecret:secret toView: self];
}

- (NSString *)getSecretWithtime:(long)time {
    
    return @"";
}

- (void)didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    [_wait hide];
    
    if([aDownload.action isEqualToString:act_GetBankCardList]){
        
        // 将数组转成model
        
        if (_page == 0) {
            [_array removeAllObjects];
            [_array addObjectsFromArray:array1];
        }
        else {
            [_array addObjectsFromArray:array1];
        }
        
        // 刷新tableView
        [self.tableView reloadData];

    }
    else if ([aDownload.action isEqualToString:act_DeleteBindBankCard]) {
        
        [self.array removeObjectAtIndex:_deleteIndex];//移除数据源的数据
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deleteIndex inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        
        [g_server showMsg:@"解除绑定成功"];
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


- (void)addBankCrad{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 76)];
    
    UIButton *addAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addAccountButton setTitle:@"添加银行卡/支付宝账号" forState:UIControlStateNormal];
    [addAccountButton setTitle:@"添加银行卡" forState:UIControlStateNormal];
    addAccountButton.layer.cornerRadius = 22;
    addAccountButton.layer.masksToBounds = YES;
    addAccountButton.titleLabel.font = [UIFont systemFontOfSize:19];
    addAccountButton.frame = CGRectMake(20, 10, JX_SCREEN_WIDTH - 40, 44);
//    addAccountButton.layer.borderColor = THEMECOLOR.CGColor;
//    addAccountButton.layer.borderWidth = 1;
    addAccountButton.backgroundColor = THEMECOLOR;
    [addAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addAccountButton addTarget:self action:@selector(addBankCardAction) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:addAccountButton];
    
    self.tableView.tableFooterView = footerView;
}

- (void)addBankCardAction {
    
    JXAddBankCardViewController * addBankCardVC = [[JXAddBankCardViewController alloc] init];
    [g_navigation pushViewController:addBankCardVC animated:YES];
}

- (void)pressAction:(UILongPressGestureRecognizer *)longPressGesture{
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        
        //手势开始
        CGPoint point = [longPressGesture locationInView:self.tableView];
        NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point]; // 可以获取我们在哪个cell上长按
        NSLog(@"%ld",currentIndexPath.row);
        
        NSDictionary *dict = self.array[currentIndexPath.row];
        [JXBankCardInfoView showConfirmViewWithBankName:dict[@"bankBrandName"] bankCard:dict[@"cardNo"] bankAddress:dict[@"openBankAddr"] userName:dict[@"userName"]];
    }
    
    //手势结束
    if (longPressGesture.state == UIGestureRecognizerStateEnded){
        
       
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell==nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSDictionary *dict = self.array[indexPath.item];
//    cell.textLabel.text = dict[@"bankBrandName"];
    
    
    NSString *bankBrandID = [NSString stringWithFormat:@"%@", dict[@"bankBrandId"]];
    NSString *imageName = [self.bankImageDictionary objectForKey:bankBrandID];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, JX_SCREEN_WIDTH - 40,  (JX_SCREEN_WIDTH - 40) / 1035 * 248)];
    imageView.image = [UIImage imageNamed:imageName];
    [cell addSubview:imageView];
    
    UILabel *bankNameLabel = [UILabel new];
    bankNameLabel.text = dict[@"bankBrandName"];
    bankNameLabel.font = [UIFont systemFontOfSize:20];
    bankNameLabel.textColor = [UIColor blackColor];
    bankNameLabel.frame = CGRectMake(160, 20, 100, 26);
//    [imageView addSubview:bankNameLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_black"]];
    arrowImageView.frame = CGRectMake(JX_SCREEN_WIDTH - 100, 50, 30, 30);
//    [imageView addSubview:arrowImageView];
    
    UILabel *cardNumLabel = [UILabel new];
    cardNumLabel.text = dict[@"cardNo"];
    cardNumLabel.font = [UIFont systemFontOfSize:20];
    cardNumLabel.textColor = [UIColor whiteColor];
    cardNumLabel.textAlignment = NSTextAlignmentLeft;
    cardNumLabel.frame = CGRectMake(82, CGRectGetMaxY(imageView.frame) - 50, 300, 26);

    [imageView addSubview:cardNumLabel];
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return true;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    if (editingStyle == UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
//
//        if (indexPath.row < [self.array count]) {
//
//            // 调用删除的接口
//            long time = (long)[[NSDate date] timeIntervalSince1970];
//            NSString *secret = [self getSecretWithtime:time];
//            NSString *cardId = self.array[indexPath.row][@"id"];
//            [g_server deleteBindCard:secret cardId:cardId toView:self];
//
//            _deleteIndex = indexPath.row;
//
//        }
//
//    }
//
//}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       
        if (indexPath.row < [self.array count]) {
            
            // 调用删除的接口
            long time = (long)[[NSDate date] timeIntervalSince1970];
            NSString *secret = [self getSecretWithtime:time];
            NSString *cardId = self.array[indexPath.row][@"id"];
            [g_server deleteBindCard:secret cardId:cardId toView:self];
            
            _deleteIndex = indexPath.row;
        }
    }];
    
    return @[deleteAction];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        if (indexPath.row < [self.array count]) {
            
            // 调用删除的接口
            long time = (long)[[NSDate date] timeIntervalSince1970];
            NSString *secret = [self getSecretWithtime:time];
            NSString *cardId = self.array[indexPath.row][@"id"];
            [g_server deleteBindCard:secret cardId:cardId toView:self];
            
            _deleteIndex = indexPath.row;
        }
    }];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    configuration.performsFirstActionWithFullSwipe = NO;
    return configuration;
                                  
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = (JX_SCREEN_WIDTH - 40) / 1035 * 248 + 20;
    return  cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.array.count;
}

@end
