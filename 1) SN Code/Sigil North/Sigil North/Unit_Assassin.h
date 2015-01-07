
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Unit.h"

@interface Unit_Assassin : Unit {
    
}

-(id)initWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;
-(BOOL)canWalkOverTile:(TileData *)td;

@end
