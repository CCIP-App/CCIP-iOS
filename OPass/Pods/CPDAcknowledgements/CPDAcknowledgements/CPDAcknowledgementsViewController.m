#import "CPDLibrary.h"
#import "CPDTableViewDataSource.h"
#import "CPDCocoaPodsLibrariesLoader.h"
#import "CPDAcknowledgementsViewController.h"
#import "CPDLibraryDetailViewController.h"
#import "CPDContribution.h"
#import "CPDContributionDetailViewController.h"
#import "CPDStyle.h"
#import <SafariServices/SFSafariViewController.h>

@interface CPDAcknowledgementsViewController () <UITableViewDelegate>
@property (nonatomic, strong) CPDTableViewDataSource *dataSource;
@property (nonatomic, strong) CPDStyle *style;
@end

@implementation CPDAcknowledgementsViewController

- (instancetype)init
{
    return [self initWithStyle:nil];
}

- (instancetype)initWithStyle:(CPDStyle *)style
{
    return [self initWithStyle:style acknowledgements:nil contributions:nil];
}

- (instancetype)initWithStyle:(CPDStyle *)style acknowledgements:(NSArray <CPDLibrary *>*)acknowledgements contributions:(NSArray <CPDContribution *>*)contributions
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    [self configureAcknowledgements:acknowledgements contributions:contributions];
    _style = style;

    self.title = @"Acknowledgements";

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self configureAcknowledgements:nil contributions:nil];
    
    self.title = @"Acknowledgements";
    
    return self;
}

- (void)configureAcknowledgements:(NSArray *)acknowledgements contributions:(NSArray *)contributions
{
    if(!acknowledgements){
        NSBundle *bundle = [NSBundle mainBundle];
        acknowledgements = [CPDCocoaPodsLibrariesLoader loadAcknowledgementsWithBundle:bundle];
    }
    
    _dataSource = [[CPDTableViewDataSource alloc] initWithAcknowledgements:acknowledgements contributions:contributions];
}

- (void)loadView
{
    [super loadView];
    self.tableView.dataSource = self.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAssert(self.navigationController, @"The AcknowledgementVC needs to be inside a navigation controller.");

}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id acknowledgement = [self.dataSource acknowledgementAtIndexPath:indexPath];

    id detailController;
    if ([acknowledgement isKindOfClass:CPDLibrary.class]){
        detailController = [[CPDLibraryDetailViewController alloc] initWithLibrary:acknowledgement];
        [detailController setCSS:self.style.libraryCSS];
        [detailController setHTML:self.style.libraryHTML];
        [detailController setHeaderHTML:self.style.libraryHeaderHTML];

    } else if([acknowledgement isKindOfClass:CPDContribution.class]){
        CPDContribution *contribution = acknowledgement;
        if (contribution.websiteAddress){
//            detailController = [[CPDContributionDetailViewController alloc] initWithContribution:contribution];
            if ([SFSafariViewController class] != nil) {
                // Open in SFSafariViewController
                SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:contribution.websiteAddress]];
                [safariViewController setDelegate:self];
                
                // SFSafariViewController Toolbar TintColor
                // [safariViewController.view setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
                // or http://stackoverflow.com/a/35524808/1751900
                
                // ProgressBar Color Not Found
                // ...
                
                UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                while ([vc presentedViewController])
                vc = [vc presentedViewController];
                [vc presentViewController:safariViewController
                                 animated:YES
                               completion:nil];
            }
            return;
        }
    }

    [self.navigationController pushViewController:detailController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource heightForCellAtIndexPath:indexPath];
}

@end
