//
//  Building_Ruins.h
//  Sigil North
//
//  Created by M F J C Clowes on 16/01/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Building.h"

@interface Building_Ruins : Building {
    
}

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;
-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;

@end
