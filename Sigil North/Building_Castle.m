//
//  Building_Castle.m
//  Sigil North
//
//  Created by M F J C Clowes on 17/11/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Building_Castle.h"


@implementation Building_Castle

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_theGame tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _theGame;
        owner= _owner;
        canHireUnits = false;
        canHeal = true;
        canGenerateMoney = true;
        buildingDefBonus = 9;
        [self createSprite:tileDict];
        [theGame addChild:self z:1];
    }
    return self;
}

@end
