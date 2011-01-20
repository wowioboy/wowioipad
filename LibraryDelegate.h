//
//  LibraryDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/10/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

@class Library;

@protocol LibraryDelegate

@required
- (void)bookItem:(Library *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Library *)item didLoadCover:(UIImage *)bookImage;

@optional


@end