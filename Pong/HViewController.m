//
//  HViewController.m
//  Pong
//
//  Created by 胡晓阳 on 14-7-24.
//  Copyright (c) 2014年 HuXiaoyang. All rights reserved.
//

#import "HViewController.h"
#define MAX_SCORE 3
@interface HViewController ()

@end

@implementation HViewController
@synthesize viewPaddle1;
@synthesize viewPaddle2;
@synthesize viewPuck;
@synthesize viewScore1;
@synthesize viewScore2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    
//    [self reset];
//    [self start];
    
    //玩家点击确定后才开始游戏
    [self newGame];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///首次在屏幕上检测到触摸
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"首次在屏幕上检测到触摸");
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        //根据手指的触摸位置决定球拍的位置
        if (touch1 == nil && touchPoint.y < self.view.frame.size.height/2) {
            //移动上屏幕上方的球拍，水平位置移动
            viewPaddle1.center = CGPointMake(touchPoint.x, viewPaddle1.center.y);
            touch1 = touch;
        }
        else if(touch2 == nil && touchPoint.y >= self.view.frame.size.height/2)
        {
            //移动上屏幕下方的球拍，水平位置移动
            viewPaddle2.center = CGPointMake(touchPoint.x, viewPaddle2.center.y);
            touch2 = touch;
        }
    }
}

///手指移动到了新的位置
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"手指移动到了新的位置");
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touch == touch1) {
            viewPaddle1.center = CGPointMake(touchPoint.x, viewPaddle1.center.y);
        }
        else if (touch == touch2)
        {
            viewPaddle2.center = CGPointMake(touchPoint.x, viewPaddle2.center.y);
                                            
        }
    }
}

///手指离开屏幕
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"手指离开屏幕");
    for (UITouch *touch in touches) {
        if (touch == touch1) {
            touch1 = nil;
        }else if (touch == touch2)
            touch2 = nil;
    }
}

///触摸被取消
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"触摸被取消");
    [self touchesEnded:touches withEvent:event];
}

///每一轮开始都要重置冰球的移动方向和速度，以及初始位置
-(void)reset
{
    //随机地设置冰球的方向 向左或者向右
    //使用arc4random()%X 生成 0到X-1 之间的随机数
    if ((arc4random()%2 == 0)) {
        dx = -1;//向左
    }else
        dx = 1;//向右
    
    //如果dy不为0，则设置dy为反方向，使冰球往对方方向滚
    if (dy != 0) {
        dy = -dy;
    }else
    {
        
        if (arc4random()%2 == 0) {
            dy = -1;//向上
        }else
            dy = 1;//向下
    }
    
    //将冰球放置在中线上
    viewPuck.center = CGPointMake(15+arc4random()%(320-30), 284);
    
    //reset speed
    speed = 2;
    
}


///判断那个玩家得分
-(BOOL)checkGoal
{
    //如果球超出边界，重置游戏，赢家得分
    if (viewPuck.center.y<0 || viewPuck.center.y >= self.view.frame.size.height) {
        //检查冰球是否超出边界，如果超出，则重置游戏
        int s1 = [viewScore1.text intValue];
        int s2 = [viewScore2.text intValue];
        
        //给赢的一方加一分
        if (viewPuck.center.y<0) {
            ++s2;
        }else
            ++s1;
        
        viewScore1.text = [NSString stringWithFormat:@"%u",s1];
        viewScore2.text = [NSString stringWithFormat:@"%u",s2];
        
        if ([self gameOver] == 1) {
            [self displayMessage:@"玩家1获胜"];
        }else if ([self gameOver] == 2)
        {
            [self displayMessage:@"玩家2获胜"];
        }
        else
            //开始新的一轮
            [self reset];
        
        
        
        
        return TRUE;

    }
    return FALSE;
}

///移动冰球，从当前的中心位置移动到一个新的位置，新位置由方向和速度决定
-(void)animate
{
    
    [self checkPuckCollision:CGRectMake(-10, 0, 20, self.view.frame.size.height) DirX:fabsf(dx) DirY:0];
    [self checkPuckCollision:CGRectMake(310, 0, 20, self.view.frame.size.height) DirX:-fabsf(dx) DirY:0];
//    NSLog(@"viewPuck.centerX:%f",viewPuck.center.x);
//    NSLog(@"viewPaddle1.centerX:%f",viewPaddle1.center.x);
//    NSLog(@"viewPaddle2.centerX:%f",viewPaddle2.center.x);
    
    if ([self checkPuckCollision:viewPaddle1.frame DirX:(viewPuck.center.x - viewPaddle1.center.x)/32.0 DirY:1]) {
        [self increaseSpeed];
    }
    
    if ([self checkPuckCollision:viewPaddle2.frame DirX:(viewPuck.center.x - viewPaddle2.center.x)/32.0 DirY:-1]) {
        [self increaseSpeed];
    }
    
    
    viewPuck.center = CGPointMake(viewPuck.center.x + dx * speed, viewPuck.center.y + dy * speed);
    
    //判断哪个玩家得分
    [self checkGoal];
}

///开始游戏动画计时器
-(void)start
{
    if (timer == nil) {
        //创建一个动画计时器
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:NULL repeats:YES];
    }
    viewPuck.hidden = NO;
}

///停止游戏动画计时器
-(void)stop
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    
    viewPuck.hidden = YES;
}



///验证给定的长方形与冰球是否相交，如果相交就将冰球的移动方向更改为指定的方向。
//新的移动方向是可选的。如果将dx和dy指定为0，则不会有任何变化
-(BOOL)checkPuckCollision:(CGRect)rect DirX:(float)x DirY:(float)y
{
    if (CGRectIntersectsRect(viewPuck.frame, rect)) {
        NSLog(@"撞了！");
        //若相撞，改变冰球方向
        if (x!=0) {
            dx = x;
        }
        
        if (y!= 0) {
            dy =y;
        }
        
        return TRUE;
    }
    
    return FALSE;
}
///向用户提示一条消息
-(void)displayMessage:(NSString *)msg
{
    //不能显示超过一个消息
    if (alert) {
        return;
    }
    
    //停止游戏
    [self stop];
    
    alert = [[UIAlertView alloc] initWithTitle:@"游戏" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

///重置一局
-(void)newGame
{
    [self reset];
    
    //将得分清零
    viewScore1.text = [NSString stringWithFormat:@"0"];
    viewScore2.text = [NSString stringWithFormat:@"0"];
    
    //提示用户新游戏开始Zxzsa
    [self displayMessage:@"准备好了吗?"];
}

///游戏结束
-(int)gameOver
{
    if ([viewScore1.text intValue] >= MAX_SCORE) {
        return 1;
    }
    if ([viewScore2.text intValue] >= MAX_SCORE) {
        return 2;
    }
    return 0;
}

///提高速度
-(void)increaseSpeed
{
    speed += 0.5;
    if (speed > 10) {
        speed = 10;
    }
}

#pragma mark -
#pragma mark UIAlertVieDelegate Method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alert = nil;
    [self reset];
    [self start];
    
    
    if ([viewScore1.text intValue] >= MAX_SCORE || [viewScore2.text intValue] >= MAX_SCORE) {
        //将得分清零
        viewScore1.text = [NSString stringWithFormat:@"0"];
        viewScore2.text = [NSString stringWithFormat:@"0"];
    }


}
#pragma mark -

-(void)resume
{
    [self displayMessage:@"游戏已被暂停！"];
}

-(void)pause
{
    [self stop];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark 处理摇一摇事件
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Shake begin");
    if (event.type == UIEventSubtypeMotionShake) {
        [self pause];
        [self resume];
    }
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Shake canclled");
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Shake ended");
}
#pragma mark -
@end
