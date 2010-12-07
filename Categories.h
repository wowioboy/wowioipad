//
//  Categories.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/23/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Categories :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * totalbooks;
@property (nonatomic, retain) NSNumber * bookcategoryid;
@property (nonatomic, retain) NSNumber * bookcount;
@property (nonatomic, retain) NSString * bookcategory;

@end



