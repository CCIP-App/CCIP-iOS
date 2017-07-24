//
//  MapsViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/25.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "MapsViewController.h"

@interface MapsViewController ()

@property (strong, nonatomic) NSArray *maps;

@end

@implementation MapsViewController

- (void)viewDidLoad {
    NSBundle *mapsBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Maps.bundle"]];
    self.maps = [mapsBundle URLsForResourcesWithExtension:@"png"
                                             subdirectory:nil];
    self.maps = [self.maps sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent"
                                                                                        ascending:YES] ]];
    self.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.maps count];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithURL:[self.maps objectAtIndex:index]];
}

@end
