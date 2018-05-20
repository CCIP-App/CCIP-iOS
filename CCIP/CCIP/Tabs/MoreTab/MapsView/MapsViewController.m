//
//  MapsViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/25.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MapsViewController.h"
#import "UIColor+addition.h"
#import "UIImage+addition.h"
#import "UIView+addition.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@interface MapsViewController ()

@property (strong, nonatomic) NSArray *maps;
@property (readwrite, nonatomic) CGRect mapThumbnailsCropArea;
@property (strong, nonatomic) MWPhotoBrowser *browser;
@property (strong, nonatomic) UINavigationController *ncBrowser;

@end

@implementation MapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSBundle *mapsBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Maps.bundle"]];
    self.maps = [mapsBundle URLsForResourcesWithExtension:@"png"
                                             subdirectory:nil];
    self.maps = [self.maps sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent"
                                                                                        ascending:YES] ]];
    NSDictionary *tarea = [NSDictionary dictionaryWithContentsOfURL:[mapsBundle URLForResource:@"thumbnails"
                                                                                 withExtension:@"plist"]];
    self.mapThumbnailsCropArea = CGRectMake(
                                            [[tarea objectForKey:@"X"] floatValue],
                                            [[tarea objectForKey:@"Y"] floatValue],
                                            [[tarea objectForKey:@"Width"] floatValue],
                                            [[tarea objectForKey:@"Height"] floatValue]
                                            );
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [self.browser setEnableGrid:YES];
    [self.browser setStartOnGrid:YES];
    [self.browser setDisplayNavArrows:YES];
    [self.browser setDisplayActionButton:NO];
    [self.browser setAlwaysShowControls:YES];    
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self.browser isVisible]) {
        
        self.ncBrowser = [[UINavigationController alloc] initWithRootViewController:self.browser];
        [self.ncBrowser setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [self presentViewController:self.ncBrowser
                           animated:NO
                         completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self.ncBrowser dismissViewControllerAnimated:YES
                                       completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.maps count];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithURL:[self.maps objectAtIndex:index]];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    NSURL *url = [self.maps objectAtIndex:index];
    UIImage *thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    CGImageRef subImage = CGImageCreateWithImageInRect(thumb.CGImage, self.mapThumbnailsCropArea);
    UIImage *cropThumb = [UIImage imageWithCGImage:subImage];
    return [MWPhoto photoWithImage:cropThumb];
}

@end

@implementation MWPhotoBrowser (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = [self class];
        
        SEL oriSEL = NSSelectorFromString(@"setNavBarAppearance:");
        SEL cusSEL = NSSelectorFromString(@"setNewNavBarAppearance:");
        
        Method ori_Method =  class_getInstanceMethod(selfClass, oriSEL);
        Method my_Method = class_getInstanceMethod(selfClass, cusSEL);
        method_exchangeImplementations(ori_Method, my_Method);
    });
}

- (void)setNewNavBarAppearance:(BOOL)animated {
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
    UIView *headView = [[UIView alloc] initWithFrame:frame];
    [headView setGradientColor:[AppDelegate AppConfigColor:@"MapTitleLeftColor"]
                            To:[AppDelegate AppConfigColor:@"MapTitleRightColor"]
                    StartPoint:CGPointMake(-.4f, .5f)
                       ToPoint:CGPointMake(1, .5f)];
    UIImage *naviBackImg = [[headView.layer.sublayers lastObject] toImage];
    [self.navigationController.navigationBar setBackgroundImage:naviBackImg
                                                  forBarMetrics:UIBarMetricsDefault];
    UIToolbar *toolbar = [self valueForKey:@"_toolbar"];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar setBackgroundImage:naviBackImg
             forToolbarPosition:UIBarPositionAny
                     barMetrics:UIBarMetricsDefault];
}

@end
