//
//  Building_Farm.m
//  Sigil North
//
//  Created by M F J C Clowes on 13/01/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "Building_Farm.h"


@implementation Building_Farm

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_theGame tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _theGame;
        owner= _owner;
        canHireUnits = true;
        canHeal = true;
        canGenerateMoney = true;
        buildingDefBonus = 6;
        [self createSprite:tileDict];
        [theGame addChild:self z:1];
    }
    return self;
}


@end
