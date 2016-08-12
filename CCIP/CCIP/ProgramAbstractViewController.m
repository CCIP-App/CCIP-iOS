//
//  ProgramAbstractViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramAbstractViewController.h"
#import <MMMarkdown/MMMarkdown.h>

@interface ProgramAbstractViewController ()

@end

@implementation ProgramAbstractViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setProgram:program];
    }
    return self;
}

-(void)setView {
    [self.roomInfo setText:[_program objectForKey:@"room"]];
    [self.langInfo setText:[_program objectForKey:@"lang"]];
    
    
    static NSDateFormatter *formatter_full = nil;
    if (formatter_full == nil) {
        formatter_full = [[NSDateFormatter alloc] init];
        [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    static NSDateFormatter *formatter_s = nil;
    if (formatter_s == nil) {
        formatter_s = [[NSDateFormatter alloc] init];
        [formatter_s setDateFormat:@"HH:mm:ss"];
    }
    
    static NSDate *startTime;
    static NSDate *endTime;
    startTime = [formatter_full dateFromString:[_program objectForKey:@"starttime"]];
    endTime = [formatter_full dateFromString:[_program objectForKey:@"endtime"]];
    
    static NSString *startTime_str;
    static NSString *endTime_str;
    startTime_str = [formatter_s stringFromDate:startTime];
    endTime_str = [formatter_s stringFromDate:endTime];
    
    static NSString *timeInfoStr;
    timeInfoStr = [NSString stringWithFormat:@"%@ ~ %@", startTime_str, endTime_str];
    
    [self.timeInfo setText:timeInfoStr];
    
    NSString *abstractMarkdownHtml = [MMMarkdown HTMLStringWithMarkdown:[_program objectForKey:@"abstract"]
                                                             extensions:MMMarkdownExtensionsGitHubFlavored
                                                                  error:nil];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *abstractMarkdownAttributedString = [[NSAttributedString alloc] initWithData:[abstractMarkdownHtml
                                                                                                     dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                            options:options
                                                                                 documentAttributes:nil
                                                                                              error:nil];
    
    [self.abstractInfo setAttributedText:abstractMarkdownAttributedString];
    //[self.abstractInfo setText:[_program objectForKey:@"abstract"]];
    
    // disable UITextView's text padding
    [self.abstractInfo setTextContainerInset:UIEdgeInsetsZero];
    [self.abstractInfo.textContainer setLineFragmentPadding:0.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.program) {
        [self setView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // scroll abstract info content to top
    [self.abstractInfo scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // scroll abstract info content to top
    [self.abstractInfo scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
    [self setView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
