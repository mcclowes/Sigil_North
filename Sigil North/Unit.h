#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"
#import "MainGameLayer.h"
#import "TileData.h"

@interface Unit : CCNode <CCTouchOneByOneDelegate> {
    //Game Layers
    MainGameLayer *mainGame;
    GameLayer *theGame;
    
    //Unit visuals
    CCSprite * mySprite;
    CCLabelBMFont * hpLabel;
    
    //Unit properties
    int movementRange;
    int attackRange;
    int unitAtk;
    int unitDef;
    int unitCost;
    BOOL canAttack;
    BOOL canCapture;
    BOOL canJoin;
    BOOL isRanged;
    BOOL isHealer;
    int owner;

    //Unit state
    touchState state;
    float hp;
    BOOL moving;
    BOOL movedThisTurn;
    BOOL attackedThisTurn;
    BOOL selectingMovement;
    BOOL selectingAttack;
    BOOL selectingJoin;

    //Movement Handling
    TileData * tileDataBeforeMovement;
    NSMutableArray *spOpenSteps;
    NSMutableArray *spClosedSteps;
    NSMutableArray *movementPath;
}
#pragma mark Variables:
//Game Layers
@property (nonatomic, retain) MainGameLayer *mainGame;
@property (nonatomic, retain) GameLayer *theGame;

//Unit Visuals
@property (nonatomic,assign) CCSprite * mySprite;
@property (nonatomic,assign) CCLabelBMFont * hpLabel;

//Unit properties
@property (nonatomic,readwrite) int movementRange;
@property (nonatomic,readwrite) int attackRange;
@property (nonatomic,readwrite) int unitAtk;
@property (nonatomic,readwrite) int unitDef;
@property (nonatomic,readwrite) int unitCost;
@property (nonatomic,readwrite) BOOL canAttack;
@property (nonatomic,readwrite) BOOL canCapture;
@property (nonatomic,readwrite) BOOL canJoin;
@property (nonatomic,readwrite) BOOL isRanged;
@property (nonatomic,readwrite) BOOL isHealer;
@property (nonatomic,readwrite) int owner;

//Unit State
@property (nonatomic,readwrite) touchState state;
@property (nonatomic,readwrite) float hp;
@property (nonatomic,readwrite) BOOL moving;
@property (nonatomic,readwrite) BOOL movedThisTurn;
@property (nonatomic,readwrite) BOOL attackedThisTurn;
@property (nonatomic,readwrite) BOOL selectingMovement;
@property (nonatomic,readwrite) BOOL selectingJoin;
@property (nonatomic,readwrite) BOOL selectingAttack;

//Movement Handling
@property (nonatomic,assign) TileData * tileDataBeforeMovement;
@property (nonatomic,assign) NSMutableArray *spOpenSteps;
@property (nonatomic,assign) NSMutableArray *spClosedSteps;
@property (nonatomic,assign)NSMutableArray *movementPath;

#pragma mark Methods:
+(id) nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;

#pragma mark Getters
-(BOOL) canWalkOverTile:(TileData *)td;
-(double) getHP;

#pragma mark Create Unit
-(void) createSprite:(NSMutableDictionary *)tileDict;

#pragma mark Unit Touch Handling
-(void) selectUnit;
-(void) unselectUnit;

#pragma mark Unit Menu Handling
-(void) markPossibleAction:(int)action;
-(void) doCancel;

#pragma mark Handling Movement
-(void) unMarkPossibleMovement;
-(void) insertOrderedInOpenSteps:(TileData *)tile;
-(int) computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord;
-(int) costToMoveFromTile:(TileData *)fromTile toAdjacentTile:(TileData *)toTile;
-(void) constructPathAndStartAnimationFromStep:(TileData *)tile;
-(void) popStepAndAnimate;
-(void) doMarkedMovement:(TileData *)targetTileData;
-(void) doStay;

#pragma mark Handling Capturing
-(void) doCapture;

#pragma mark Handling Healing
-(void) doHealing1;
-(void) doHealing2;

#pragma mark Handling Attacks
-(void) doAttack;
-(void) unMarkPossibleAttack;
-(void) doMarkedAttack:(TileData *)targetTileData;
-(void) attackedBy:(Unit *)attacker firstAttack:(BOOL)firstAttack;
-(void) dealDamage:(NSMutableDictionary *)damageData;

#pragma mark Handling Joining
-(void) doJoin;
-(void) unMarkPossibleJoin;
-(void) doMarkedJoin:(TileData *)targetTileData;
-(void) joinedBy:(Unit *)joiner joining:(Unit *)target;
-(void) join:(NSMutableDictionary *)joiningData;

#pragma mark Maintenance
-(void) startTurn;
-(void) updateHpLabel;
-(void) removeExplosion:(CCSprite *)e;
-(void) removeHealingAnimation:(CCSprite *)e;

@end