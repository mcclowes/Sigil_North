//
//  Building.h
//  Sigil North
//
//  Created by M F J C Clowes on 17/11/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"
#import "MainGameLayer.h"

@class MainGameLayer;
@class GameLayer;
@class HUDLayer;

@interface Building : CCNode {
    //Game Layers
    MainGameLayer *mainGame;
    GameLayer *theGame; //need this?
    
    //Building visuals
    CCSprite *mySprite;
    CCLabelBMFont *captureLabel;
    
    //Building properties
    int buildingDefBonus;
    BOOL canHeal;
    BOOL canHireUnits;
    BOOL canGenerateMoney;
    int owner;
    
    //Building state
    touchState state;
    float captureLevel;
    BOOL selectingUnit;
    BOOL hiringUnit;
    BOOL hiredThisTurn;

}
#pragma mark Variables:
//Game Layers
@property (nonatomic, retain) MainGameLayer *mainGame;
@property (nonatomic, retain) GameLayer *theGame;

//Building visuals
@property (nonatomic,assign) CCSprite *mySprite;
@property (nonatomic,assign) CCLabelBMFont * captureLabel;

//Building properties
@property (nonatomic, readwrite) int buildingDefBonus;
@property (nonatomic,readwrite) BOOL canHeal;
@property (nonatomic,readwrite) BOOL canHireUnits;
@property (nonatomic,readwrite) BOOL canGenerateMoney;
@property (nonatomic,readwrite) int owner;

//Building state
@property (nonatomic,readwrite) touchState state;
@property (nonatomic,readwrite) float captureLevel;
@property (nonatomic,readwrite) BOOL selectingUnit;
@property (nonatomic,readwrite) BOOL hiringUnit;
@property (nonatomic,readwrite) BOOL hiredThisTurn;

#pragma mark Methods:
+(id) nodeWithTheGame:(GameLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;//???

#pragma mark Getters
-(BOOL) getCanHeal;
-(BOOL) getCanHireUnits;

#pragma mark Create Building
-(void) createSprite:(NSMutableDictionary *)tileDict;

#pragma mark Building Touch Handling
-(void) selectBuilding;
-(void) unselectBuilding;
-(void) doCancel;

#pragma mark Hiring Handling
-(void) hireFootman;
-(void) hireCenturion;
-(void) hireRanger;
-(void) hireBattleMage;
-(void) hirePriest;
-(void) createHiredUnit:(NSString *)givenUnitType;
-(void) doFinishHiring;

#pragma mark Capture Handling
-(void) createCaptureLabel;

#pragma mark Maintenance
-(void) startTurn;
-(void) updateCaptureLabel;

@end