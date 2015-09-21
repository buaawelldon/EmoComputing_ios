//
//  ViewController.h
//  test2
//
//  Created by Christina Tsangouri on 9/9/15.
//  Copyright (c) 2015 Christina Tsangouri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController <CvVideoCameraDelegate>
{
    CvVideoCamera *camera;
}

@property (nonatomic,retain) CvVideoCamera *camera;


@property (weak, nonatomic) IBOutlet UIImageView *faceView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) NSString *highEmotion;

//@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@property (weak, nonatomic) IBOutlet UIToolbar *onButton;

@property (weak, nonatomic) IBOutlet UIToolbar *offButton;

//@property (weak, nonatomic) IBOutlet UIButton *startCamera;

@property (weak, nonatomic) IBOutlet UIButton *startCamera;


@end

