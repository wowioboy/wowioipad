//
//  Sponsored.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/23/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Sponsored :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bookcount;
@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSString * coverimagepath_s;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * mainbookcategoryid;
@property (nonatomic, retain) NSString * publicationdate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * retailprice;
@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSString * publishername;
@property (nonatomic, retain) NSNumber * pagecount;

@end



