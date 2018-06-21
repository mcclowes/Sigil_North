
#import "Unit_Ranger.h"

@implementation Unit_Ranger

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
        isRanged = true;
        isHealer = false;
        movementRange = 9;
        attackRange = 2;
        unitAtk = 5;
        unitDef = 10;
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