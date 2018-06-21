
#import "Unit_Scout.h"

@implementation Unit_Scout

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
        movementRange = 16;
        attackRange = 1;
        unitAtk = 3;
        unitDef = 3;
        unitCost = 250;
        hp=100;
        [self createSprite:tileDict];
        [theGame addChild:self z:3];
    }
    return self;
}

-(BOOL)canWalkOverTile:(TileData *)td {
    return YES;
}

@end