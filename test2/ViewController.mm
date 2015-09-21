//
//  ViewController.m
//  test2
//
//  Created by Christina Tsangouri on 9/9/15.
//  Copyright (c) 2015 Christina Tsangouri. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>


@interface ViewController ()

-(cv::CascadeClassifier*)loadClassifier;


@end

@implementation ViewController

cv::Mat faceMat;
cv::Mat originalMat;
UIImage *image;
cv::Mat grayMat;
cv::Mat tempMat;
UIImage *newImage;
cv::CascadeClassifier *faceCascade;
UIImage *faceImage;
bool faceDetected = false;
cv::Rect roi;

-(cv::CascadeClassifier*)loadClassifier
{
    NSString* haar = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface" ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([haar UTF8String]);
    return cascade;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
   
    [self.startCamera setTitle:@"Start Camera" forState:UIControlStateNormal];
    [self.resultButton setTitle:@"Show Result" forState:UIControlStateNormal];
    
    
    

    
    self.highEmotion = @"happy";
    
    self.camera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 15;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    
    faceCascade = [self loadClassifier];
    
   
   // [self showResult];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)viewDidAppear:(BOOL)animated {
    [self.imageView setImage:[UIImage imageNamed:@"coffeebeans.png"]];
}*/



- (void)showResult {
    if([self.highEmotion isEqualToString:@"happy"])
        [self.imageView setImage:[UIImage imageNamed:@"happy.jpeg"]];
    if([self.highEmotion isEqualToString:@"angry"])
        [self.imageView setImage:[UIImage imageNamed:@"angry.jpeg"]];
    if([self.highEmotion isEqualToString:@"disgust"])
        [self.imageView setImage:[UIImage imageNamed:@"disgust.jpeg"]];
    if([self.highEmotion isEqualToString:@"laughing"])
        [self.imageView setImage:[UIImage imageNamed:@"laughing.jpeg"]];
    if([self.highEmotion isEqualToString:@"neutral"])
        [self.imageView setImage:[UIImage imageNamed:@"neutral.jpeg"]];
    if([self.highEmotion isEqualToString:@"sad"])
        [self.imageView setImage:[UIImage imageNamed:@"sad.jpeg"]];
    if([self.highEmotion isEqualToString:@"fear"])
        [self.imageView setImage:[UIImage imageNamed:@"scared.jpeg"]];
    if([self.highEmotion isEqualToString:@"surprise"])
        [self.imageView setImage:[UIImage imageNamed:@"surprised.jpeg"]];
    
        
}

- (IBAction)handleResultClick:(id)sender {
    [self showFace];
    
    //[self showResult];
}

/*- (IBAction)handleButtonClick:(id)sender {
    
    [self getMat];
    
    
    
    //self.textLabel.text = @"button pressed";
}*/

- (IBAction)handleStartCamera:(id)sender {
    [self.camera start];
    
}

#pragma mark - Protocol CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV stuff with the image
    cv::Mat grayMat;
    cv::Mat face;
    cv::Mat rgbMat;
    grayMat = cv::Mat(image.rows, image.cols, CV_8UC3);
    cvtColor(image, grayMat, CV_BGRA2GRAY);
    rgbMat = cv::Mat(image.rows, image.cols, CV_8UC3);
    cvtColor(image, rgbMat, CV_BGRA2RGB);
    
    int height = grayMat.rows;
    double faceSize = (double) height * 0.25;
    cv::Size sSize;
    sSize.height = faceSize;
    sSize.width = faceSize;
    std::vector<cv::Rect> faces;
    
    faceCascade->detectMultiScale(grayMat,faces,1.1,4,2, sSize);
    if(faces.size() > 0)
    {
        NSLog(@"face detected!");
        cv::rectangle(image, faces[0].tl(), faces[0].br(),cv::Scalar(84.36,170,0), 2, CV_AA);
        
        cv::Mat(rgbMat, faces[0]).copyTo(face);
        
        faceImage = [self UIImageFromCVMat:face];
        
        
    }
    
    if(faces.size() == 0)
        faceDetected = false;
    
    
    grayMat.release();
    originalMat.release();
    rgbMat.release();
    
    
}

- (void)showFace {
    
    [self.faceView setImage:faceImage];
    
    // Save Face Image to Doc Directory
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString* path =  [docs stringByAppendingFormat:@"/image1.jpg"];
    
    //filename = imageData
    NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(faceImage, 80)];
    NSError *writeError = nil;
   [imageData writeToFile:path options:NSDataWritingAtomic error:&writeError];
    
    
    // Send to server
    
   // [self postImage];
    
}

/*- (void)postImage {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];

}*/

- (void)getMat {
    
    image = [UIImage imageNamed:@"face.png"];
    faceMat = [self cvMatFromUIImage:image];
    cvtColor(faceMat, grayMat, CV_BGRA2GRAY);
    newImage = [self UIImageFromCVMat:grayMat];
    [self.imageView setImage:newImage];
    
    
       // NSLog(@"things worked");
    
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}







@end
