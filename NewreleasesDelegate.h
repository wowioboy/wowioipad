//
//  NewreleasesDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 10/11/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

@class Newreleases;

@protocol NewreleasesDelegate

@required
- (void)bookItem:(Newreleases *)item couldNotLoadImageError:(NSError *)error;
- (void)bookItem:(Newreleases *)item didLoadCover:(UIImage *)image;

@optional
//- (void)bookItem:(Newreleases *)item didLoadBookImage:(UIImage *)image;



@end
