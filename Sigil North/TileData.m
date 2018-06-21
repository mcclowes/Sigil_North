#import "TileData.h"
#import "GameLayer.h"

@implementation TileData

@synthesize theGame;
@synthesize position, parentTile, movementCost, defensiveBonus, hScore, gScore, fScore, tileType;
@synthesize selectedForMovement, selectedForAttack, selectedForJoin;

+(id)nodeWithTheGame:(GameLayer *)_theGame movementCost:(int)_movementCost defensiveBonus:(int)_defensiveBonus position:(CGPoint)_position tileType:(NSString *)_tileType {
	return [[[self alloc] initWithTheGame:_theGame movementCost:_movementCost defensiveBonus:(int)_defensiveBonus position:_position tileType:_tileType] autorelease];
}

-(id)initWithTheGame:(GameLayer *)_theGame movementCost:(int)_movementCost defensiveBonus:(int)_defensiveBonus position:(CGPoint)_position tileType:(NSString *)_tileType {
	if ((self=[super init])) {
		theGame = _theGame;
        selectedForMovement = NO;
        selectedForAttack = NO;
        selectedForJoin = NO;
        movementCost = _movementCost;
        defensiveBonus = _defensiveBonus;
        tileType = _tileType;
        position = _position;
        parentTile = nil;
        [theGame addChild:self];
	}
	return self;
}

-(int)getGScore {
    int parentCost = 0;
    if (parentTile) {
        parentCost = [parentTile getGScore];
    }
    return movementCost + parentCost;
}

-(int)getGScoreForAttack {
    int parentCost = 0;
    if(parentTile) {
        parentCost = [parentTile getGScoreForAttack];
    }
    return 1 + parentCost;
}

-(int)fScore {
	return self.gScore + self.hScore;
}

-(int)getDefensiveBonus{
    return defensiveBonus;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@  pos=[%.0f;%.0f]  g=%d  h=%d  f=%d", [super description], self.position.x, self.position.y, self.gScore, self.hScore, [self fScore]];
}

@end