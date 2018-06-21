//
//  Building_Bestiary.m
//  Sigil North
//
//  Created by M F J C Clowes on 16/01/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "Building_Bestiary.h"


@implementation Building_Bestiary

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
        buildingDefBonus = 9;
        [self createSprite:tileDict];
        [theGame addChild:self z:1];
    }
    return self;
}

@end
