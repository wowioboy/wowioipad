//
//  LibraryDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

@class Library;

@protocol LibraryDelegate

@required
- (void)bookItem:(Library *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Library *)item didLoadCover:(UIImage *)image;

@optional


@end