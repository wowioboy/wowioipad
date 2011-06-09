//
//  Agilespace.h
//  WOWIO
//
//  Created by Lawrence Leach on 8/17/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Agilespace :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * totalrecords;
@property (nonatomic, retain) NSString * contenthtml;
@property (nonatomic, retain) NSString * contenthtmlipad;

@end



