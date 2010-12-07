//
//  Staffpicks.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/25/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Staffpicks :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSNumber * recstatus;
@property (nonatomic, retain) NSNumber * spid;
@property (nonatomic, retain) NSString * coverimagepath_s;
@property (nonatomic, retain) NSString * coverimagepath_l;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * mainbookcategoryid;
@property (nonatomic, retain) NSString * publicationdate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * adminid;
@property (nonatomic, retain) NSNumber * sptypeid;
@property (nonatomic, retain) NSNumber * retailprice;
@property (nonatomic, retain) NSString * bookcategoryid;
@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSString * publishername;
@property (nonatomic, retain) NSNumber * pagecount;

@end



