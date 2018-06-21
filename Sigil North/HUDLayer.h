//
//  HUDLayer.h
//  Sigil North
//
//  Created by M F J C Clowes on 26/03/2014.
//  Copyright (c) 2014 M F J C Clowes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainGameLayer.h"

@class GameLayer;
@class MainLayer;

@interface HUDLayer : CCLayer {
    //Game Layers
    MainGameLayer *_mainGame;
    HUDLayer * _hud;
    
    //Game size variables
    CGSize wins;
    
    //UI Menu Elements
    CCMenuItemImage *iconPause;
    CCMenuItemImage *iconNext;
    CCMenuItemImage *iconCycle;
    CCLabelBMFont *turnLabel;
    CCLabelBMFont *moneyLabel;
    CCSprite *uiBG;
    CCSprite *uiStarMeter;
    CCMenuItemImage * uiMin;
    CCMenu *menu;
    
    //Options Menu Elements
    CCMenu *optionsMenu;
    CCMenu *optionsMenuBack;
}
#pragma mark Variables:
//Game layers
@property (nonatomic, retain) MainGameLayer *_mainGame;
@property (nonatomic, retain) HUDLayer * _hud;
@property (nonatomic, retain) GameLayer *_theGame;

//Game size variables
@property CGSize wins;

//UI Menu Elements
@property (nonatomic, assign) CCMenuItemImage *iconPause;
@property (nonatomic, assign) CCMenuItemImage *iconNext;
@property (nonatomic, assign) CCMenuItemImage *iconCycle;
@property (nonatomic, assign) CCLabelBMFont *turnLabel;
@property (nonatomic, assign) CCLabelBMFont *moneyLabel;
@property (nonatomic, assign) CCSprite *uiBG;
@property (nonatomic, assign) CCSprite *uiStarMeter;
@property (nonatomic, assign) CCMenuItemImage *uiMin;
@property (nonatomic, assign) CCMenu *menu;

//Options Menu Elements
@property (nonatomic, assign) CCMenu *optionsMenu;
@property (nonatomic, assign) CCMenu *optionsMenuBack;

#pragma mark Methods:
-(id)init;

#pragma mark UI Menu Handling
-(void)addMenu;
-(void)setPlayerTurnLabel;

#pragma mark Options Menu Handling
-(void)doShowOptionsMenu;
-(void)doCloseOptionsMenu;

#pragma mark Options Menu Selector Methods
-(void) doSelectEndTurn;
-(void) doSelectRestartLevel;
-(void) doSelectLevelSelect;
-(void) doSelectQuitGame;

@end