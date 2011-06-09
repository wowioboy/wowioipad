//
//  TopbooksDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/9/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

@class Topbooks;

@protocol TopbooksDelegate

@required
- (void)bookItem:(Topbooks *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Topbooks *)item didLoadCover:(UIImage *)bookImage;

@optional
//- (void)bookItem:(Topbooks *)item didLoadBookImage:(UIImage *)image;


@end