//
//  ModifiedDocumentsViewController.h
//  Licenta2
//
//  Created by Seby Feier on 19/04/15.
//  Copyright (c) 2015 Seby Feier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModifiedDocumentDelegate <NSObject>

- (void)closeButtonTapped;

@end

@interface ModifiedDocumentsViewController : UIViewController

@property (nonatomic, assign) id<ModifiedDocumentDelegate>delegate;
@property (nonatomic, strong) NSArray *modifiedDocuments;

@end
