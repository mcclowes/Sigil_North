
#import "Unit_LightMage.h"


@implementation Unit_LightMage

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_theGame tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _theGame;
        owner= _owner;
        canAttack = true;
        canCapture = true;
        canJoin = true;
        isRanged = false;
        isHealer = false;
        movementRange = 9;
        attackRange = 1;
        unitAtk = 5;
        unitDef = 8;
        unitCost = 700;
        hp=100;
        [self createSprite:tileDict];
        [theGame addChild:self z:3];
    }
    return self;
}

-(BOOL)canWalkOverTile:(TileData *)td {
    if ([td.tileType isEqualToString:@"River"]) {
        return NO;
    }
    return YES;
}

@end
