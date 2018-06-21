//
//  GameLayer.h
//  Sigil North
//
//  Created by M F J C Clowes on 30/03/2014.
//  Copyright (c) 2014 M F J C Clowes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameLayer.h"
#import "MainMenuLayer.h"

@class TileData;
@class Unit;
@class Building;
@class MainGameLayer;
@class HUDLayer;

@interface GameLayer : CCLayer {
    //Game Layers
    MainGameLayer *_mainGame;
    GameLayer *_theGame;
    
    //Object arrays
    NSMutableArray *tileDataArray;
    NSMutableArray *p1Units;
    NSMutableArray *p2Units;
    NSMutableArray *p1Buildings;
    NSMutableArray *p2Buildings;
    NSMutableArray *eBuildings;
    
    //Game size variables
    CGSize wins;
    int mapWidth;
    int mapHeight;
    float mapScale;
    float distance;
    float lastGoodDistance;
    
    //Game elements
    CCTMXTiledMap *levelMap;
    Unit *selectedUnit;
    Building *selectedBuilding;
    CCTMXLayer *bgLayer;
    CCTMXLayer *objectLayer;
    
    //Menu elements
    CCMenu *unitActionsMenu;
    CCMenu *buildingActionsMenu;
    CCSprite *contextMenuBack;
    
}
#pragma mark Variables:
//Game layers
@property (nonatomic, retain) MainGameLayer *_mainGame;
@property (nonatomic, retain) HUDLayer * _hud;
@property (nonatomic, retain) GameLayer *_theGame;

//Object arrays
@property (nonatomic, assign) NSMutableArray *tileDataArray;
@property (nonatomic, assign) NSMutableArray *p1Units;
@property (nonatomic, assign) NSMutableArray *p2Units;
@property (nonatomic, assign) NSMutableArray *p1Buildings;
@property (nonatomic, assign) NSMutableArray *p2Buildings;
@property (nonatomic, assign) NSMutableArray *eBuildings;

//Game size variables
@property CGSize wins;
@property int mapWidth;
@property int mapHeight;
@property float mapScale;
@property float distance;
@property float lastGoodDistance;

//Game elements
@property (nonatomic,assign) CCTMXTiledMap *levelMap;
@property (nonatomic, assign) Unit *selectedUnit;
@property (nonatomic, assign) Building *selectedBuilding;
@property (nonatomic, assign) CCTMXLayer *bgLayer;
@property (nonatomic, assign) CCTMXLayer *objectLayer;

//Menu Elements
@property (nonatomic, assign) CCMenu *unitActionsMenu;
@property (nonatomic, assign) CCMenu *buildingActionsMenu;
@property (nonatomic, assign) CCSprite *contextMenuBack;

#pragma mark Methods:
- (id)init;

#pragma mark Tile Handling
-(int)spriteScale;
-(void)createLevelMap;
-(int)getTileHeightForRetina;
-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(CGPoint)positionForTileCoord:(CGPoint)position;
-(NSMutableArray *)getTilesNextToTile:(CGPoint)tileCoord;
-(TileData *)getTileData:(CGPoint)tileCoord;

#pragma mark Unit Handling
-(Unit *) otherUnitInTile:(TileData *)tile;
-(Unit *) otherEnemyUnitInTile:(TileData *)tile unitOwner:(int)owner;
-(Unit *)otherJoinableUnitInTile:(TileData *)tile unitOwner:(int)owner unitType:(Unit*) class;
-(BOOL)paintMovementTile:(TileData *)tData;
-(void)unPaintMovementTile:(TileData *)tileData;
-(void)loadUnits:(int)player;
-(void)selectUnit:(Unit *)unit;
-(void)unselectUnit;
-(Unit *)unitInTile:(TileData *)tile;
-(void)showUnitActionsMenu:(Unit *)unit canAttack:(BOOL)canAttack canJoin:(BOOL)canJoin canCapture:(BOOL)canCapture;
-(void)removeUnitActionsMenu;

#pragma mark Building Handling
-(void)loadBuildings:(int)player;
-(void)selectBuilding:(Building *)building;
-(void)unselectBuilding;
-(Building *)buildingInTile:(TileData *)tile;
-(void)showBuildingActionsMenu:(Building *)building canHireUnit:(BOOL)canHire;
-(void)removeBuildingActionsMenu;

#pragma mark uiMenu
-(void)doEndTurn;
-(void)doHealing;
-(void)doLevelSelect;
-(void)doRestartLevel;
-(void)restartGame;

-(void)beginTurn;
-(void)doGenerateMoney;
-(void)updateMoneyLabel;
-(void)removeLayer:(CCNode *)n;
-(void)activateUnits:(NSMutableArray *)units;
-(BOOL)checkAttackTile:(TileData *)tData unitOwner:(int)owner;
-(BOOL)checkJoinTile:(TileData *)tData unitOwner:(int)owner joinerType:(Unit *) joiner;
-(BOOL)paintAttackTile:(TileData *)tData;
-(void)unPaintAttackTiles;
-(void)unPaintAttackTile:(TileData *)tileData;
-(double)calculateDamageFrom:(Unit *)attacker onDefender:(Unit *)defender;
-(void)checkForMoreUnits;
-(void)showEndGameMessageWithWinner:(int)winningPlayer;

#pragma mark Scrolling??
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
