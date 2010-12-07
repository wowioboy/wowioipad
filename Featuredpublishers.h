//
//  Featuredpublishers.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/25/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Featuredpublishers :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * mainbookcategoryid;
@property (nonatomic, retain) NSString * coverimagepath_s;
@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * retailprice;
@property (nonatomic, retain) NSNumber * publisherid;
@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSString * publishername;
@property (nonatomic, retain) NSString * publisherurl;

@end



