//
//  ImageBrowser.m
//  objectCase
//
//  Created by JUMP on 2016/5/13.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "ImageBrowser.h"

static CGRect oldframe;

@implementation ImageBrowser

+(void) showImage:(UIImageView*)oldImageView{
    
    UIImage *image = oldImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:backgroundView.frame];
    scrollView.contentSize = backgroundView.frame.size;
    scrollView.maximumZoomScale = 5.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.zoomScale = 1.0;
    
    
    oldframe = [oldImageView convertRect:oldImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor whiteColor];
    backgroundView.alpha = 0.1; //沒反應？
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    
    
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,
                                   ([UIScreen mainScreen].bounds.size.height -
                                    image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2,
                                   [UIScreen mainScreen].bounds.size.width,
                                   image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

@end















