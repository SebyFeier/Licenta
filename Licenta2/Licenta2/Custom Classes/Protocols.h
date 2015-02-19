//
//  Protocols.h
//  Licenta
//
//  Created by Sebastian Feier on 1/6/15.
//  Copyright (c) 2015 Sebastian Feier. All rights reserved.
//

#ifndef Licenta_Protocols_h
#define Licenta_Protocols_h

@protocol DocumentViewControllerDelegate <NSObject>

- (void)selectionButtonTapped:(NSIndexPath *)indexPath canEdit:(BOOL)canEdit;

@end

#endif
