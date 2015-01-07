
#import "Unit_ArmWagon.h"

@implementation Unit_ArmWagon

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_theGame tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _theGame;
        owner= _owner;
        canAttack = true;
        canCapture = false;
        canJoin = true;
        isRanged = false;
        isHealer = false;
        movementRange = 8;
        attackRange = 1;
        unitAtk = 0;
        unitDef = 10;
        unitCost = 1500;
        hp=100;
        [self createSprite:tileDict];
        [theGame addChild:self z:3];
    }
    return self;
}

-(BOOL)canWalkOverTile:(TileData *)td {
    if ([td.tileType isEqualToString:@"Mountain"] || [td.tileType isEqualToString:@"River"]) {
        return NO;
    }
    return YES;
}

@end