//
//  JcMessageView.h
//  TheCountdownButton
//
//  Created by zjc on 2017/6/20.
//  Copyright © 2017年 zjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JcMessageView : UIView
+ (JcMessageView *)sharedInstance;
//居中显示
-(void)ShowMessage:(NSString *)msg;

@end
