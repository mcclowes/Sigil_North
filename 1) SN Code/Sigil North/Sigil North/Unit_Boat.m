
#import "Unit_Boat.h"

@implementation Unit_Boat

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_theGame tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _theGame;
        owner= _owner;
        canAttack = false;
        canCapture = false;
        //While a boat holds a unit, it cannot join
        canJoin = true;
        isRanged = false;
        isHealer = false;
        movementRange = 10;
        attackRange = 1;
        unitAtk = 0;
        unitDef = 12;
        unitCost = 800;
        hp=100;
        [self createSprite:tileDict];
        [theGame addChild:self z:3];
    }
    return self;
}

-(BOOL)canWalkOverTile:(TileData *)td {
    if ([td.tileType isEqualToString:@"River"]) {
        return YES;
    }
    return NO;
}

@end