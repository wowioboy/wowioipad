//
//  AgilebookDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 12/1/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//


@class Book;

@protocol BookDelegate

@required
- (void)bookItem:(Book *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Book *)item didLoadCover:(UIImage *)bookImage;

@optional

@end
