//
//  HViewController.h
//  Pong
//
//  Created by 胡晓阳 on 14-7-24.
//  Copyright (c) 2014年 HuXiaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HViewController : UIViewController<UIAlertViewDelegate>
{
    UITouch *touch1;
    UITouch *touch2;
    
    //设定此计时器来周期性地调用animate函数，时间间隔为1/60秒或者每秒60帧
    NSTimer *timer;
    
    //冰球
    float dx;
    float dy;
    float speed;
    
    UIAlertView *alert;
}
@property (strong, nonatomic) IBOutlet UIImageView *viewPaddle1;
@property (strong, nonatomic) IBOutlet UIImageView *viewPaddle2;
@property (strong, nonatomic) IBOutlet UIImageView *viewPuck;
@property (strong, nonatomic) IBOutlet UILabel *viewScore1;
@property (strong, nonatomic) IBOutlet UILabel *viewScore2;


-(void)resume;//提示用户游戏已被暂停
-(void)pause;//暂停游戏动画计时器



@end
