//
//  ModifiedDocumentsViewController.m
//  Licenta2
//
//  Created by Seby Feier on 19/04/15.
//  Copyright (c) 2015 Seby Feier. All rights reserved.
//

#import "ModifiedDocumentsViewController.h"

@interface ModifiedDocumentsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ModifiedDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *updatedDocuments = @"";
    for (NSString *document in self.modifiedDocuments) {
        updatedDocuments = [updatedDocuments stringByAppendingString:[NSString stringWithFormat:@"%@, ", document]];
    }
    self.textLabel.text = [NSString stringWithFormat:@"Some documents (%@) have been updated since your last login", updatedDocuments];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonTapped)]) {
            [self.delegate closeButtonTapped];
        }
    }];
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
