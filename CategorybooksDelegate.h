//
//  CategorybooksDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/10/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

@class Categorybooks;

@protocol CategorybooksDelegate

@required
- (void)bookItem:(Categorybooks *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Categorybooks *)item didLoadCover:(UIImage *)bookImage;

@optional


@end