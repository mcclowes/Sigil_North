#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameLayer.h"

@class GameLayer;

@interface TileData : CCNode {
    //Game Layers
    GameLayer *theGame;
    
    //Tile Properties
    CGPoint position;
    TileData *parentTile;
    int movementCost;
    int defensiveBonus;
    int hScore;
    int gScore;
    int fScore;
    NSString * tileType;
    
    //Tile state
    BOOL selectedForMovement;
    BOOL selectedForAttack;
    BOOL selectedForJoin;
}
#pragma mark Variables:
//Game Layers
@property (nonatomic, retain) GameLayer *theGame;

//Tile Properties
@property (nonatomic,assign) CGPoint position;
@property (nonatomic,assign) TileData * parentTile;
@property (nonatomic,readwrite) int movementCost;
@property (nonatomic,readwrite) int defensiveBonus;
@property (nonatomic,readwrite) int hScore;
@property (nonatomic,readwrite) int gScore;
@property (nonatomic,readwrite) int fScore;
@property (nonatomic,assign) NSString *tileType;

//Tile state
@property (nonatomic,readwrite) BOOL selectedForAttack;
@property (nonatomic,readwrite) BOOL selectedForJoin;
@property (nonatomic,readwrite) BOOL selectedForMovement;


#pragma mark Methods:
+(id)nodeWithTheGame:(GameLayer *)_theGame movementCost:(int)_movementCost defensiveBonus:(int)_defensiveBonus position:(CGPoint)_position tileType:(NSString *)_tileType;
-(id)initWithTheGame:(GameLayer *)_theGame movementCost:(int)_movementCost defensiveBonus:(int)_defensiveBonus position:(CGPoint)_position tileType:(NSString *)_tileType;

#pragma mark Getters
-(int)getGScore;
-(int)getGScoreForAttack;
-(int)fScore;
-(int)getDefensiveBonus;

@end