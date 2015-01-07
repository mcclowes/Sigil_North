//
//  HUDLayer.m
//  Sigil North
//
//  Created by M F J C Clowes on 26/03/2014.
//  Copyright (c) 2014 M F J C Clowes. All rights reserved.
//

#import "HUDLayer.h"
#import "MainMenuLayer.h"
#import "MainGameLayer.h"
#import "GameLayer.h"

extern int player1;
extern int player2;

@implementation HUDLayer

@synthesize _mainGame, _theGame, _hud;
@synthesize wins;
@synthesize iconPause, iconNext, iconCycle, turnLabel, moneyLabel, uiBG, uiStarMeter, uiMin, menu;
@synthesize optionsMenu, optionsMenuBack;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HUDLayer *layer = [HUDLayer node];
	[scene addChild: layer];
	return scene;
}

- (id)init {
    if ((self = [super init])) {
        wins = [[CCDirector sharedDirector] winSize];
        
        [self addMenu];
    }
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark UI Menu Handling
// Add the player turn menu
-(void)addMenu {

    wins = [[CCDirector sharedDirector] winSize];
    // Set up the menu background and position
    uiBG = [CCSprite spriteWithFile:@"uiExpanded.png"];
    [self addChild:uiBG z:5];
    [uiBG setPosition:ccp([uiBG boundingBox].size.width/2,wins.height-[uiBG boundingBox].size.height/2)];
    
    //add startpower meter
    uiStarMeter = [CCSprite spriteWithFile:[NSString stringWithFormat:@"uiStarPower_P%d.png", player1]];
    [self addChild:uiStarMeter z:4];
    [uiStarMeter setPosition:ccp([uiStarMeter boundingBox].size.width/2,wins.height-[uiStarMeter boundingBox].size.height/2)];
    
    //Show money
    moneyLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", _mainGame.player1Gold] fntFile:@"Font_silver_size17.fnt"];
    [self addChild:moneyLabel z:6];
    [moneyLabel setPosition:ccp(530,300)];
    
    // Create Action buttons
    iconPause = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"pauseIcon_P%d.png", player1] selectedImage:@"pauseIconPressed.png" target:self selector:@selector(doShowOptionsMenu)];
    iconNext = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"nextIcon_P%d.png", player1] selectedImage:@"nextIconPressed.png" target:self selector:@selector(doSelectEndTurn)];
    iconCycle = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"nextIcon_P%d.png", player1] selectedImage:@"cycleIconPressed.png" target:self selector:@selector(doSelectEndTurn)];
    //add to menu
    menu = [CCMenu menuWithItems:iconPause, iconNext, iconCycle, nil];
    [self addChild:menu z: 6];
    
    [menu setPosition:ccp(0,0)];
    
    [iconNext setPosition:ccp((44.5+ [iconNext boundingBox].size.width/2), (wins.height - [iconNext boundingBox].size.height/2 - 4))];
    [iconPause setPosition:ccp((30+ [iconPause boundingBox].size.width/2), (wins.height - [iconPause boundingBox].size.height*1.5 - 6))];
    [iconCycle setPosition:ccp((3+ [iconCycle boundingBox].size.width/2), (wins.height - [iconCycle boundingBox].size.height*2.25 - 3))];
    
    // Set the turn label to display the current turn
    [self setPlayerTurnLabel];
}

-(void)setPlayerTurnLabel {
    // Change the label colour based on the player
    if (_mainGame.playerTurn ==1) {
        [uiStarMeter setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"uiStarPower_P%d.png", player1]]];
        [iconPause setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"pauseIcon_P%d.png", player1]]];
        [iconNext setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"nextIcon_P%d.png", player1]]];
        [iconCycle setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"cycleIcon_P%d.png", player1]]];
        [moneyLabel setString:[NSString stringWithFormat:@"%d",_mainGame.player1Gold]];
    } else if (_mainGame.playerTurn == 2) {
        [uiStarMeter setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"uiStarPower_P%d.png", player2]]];
        [iconPause setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"pauseIcon_P%d.png", player2]]];
        [iconNext setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"nextIcon_P%d.png", player2]]];
        [iconCycle setNormalImage:[CCSprite spriteWithFile:[NSString stringWithFormat:@"cycleIcon_P%d.png", player2]]];
        [moneyLabel setString:[NSString stringWithFormat:@"%d",_mainGame.player2Gold]];
    }
}

#pragma mark Options Menu Handling
-(void) doShowOptionsMenu{
    //Create the menu background
    optionsMenuBack = [CCSprite spriteWithFile:@"popup_bg.png"];
    [self addChild:optionsMenuBack z:19];
    
    // Create the menu option labels
    CCLabelBMFont * resumeLbl = [CCLabelBMFont labelWithString:@"Resume" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * resumeBtn = [CCMenuItemLabel itemWithLabel:resumeLbl target:self selector:@selector(doCloseOptionsMenu)];
    //Change to restart the level
    CCLabelBMFont * restartLbl = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * restartBtn = [CCMenuItemLabel itemWithLabel:restartLbl target:self selector:@selector(doSelectRestartLevel)];
    CCLabelBMFont * levelLbl = [CCLabelBMFont labelWithString:@"Level Select" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * levelBtn = [CCMenuItemLabel itemWithLabel:levelLbl target:self selector:@selector(doSelectLevelSelect)];
    CCLabelBMFont * quitLbl = [CCLabelBMFont labelWithString:@"Quit" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * quitBtn = [CCMenuItemLabel itemWithLabel:quitLbl target:self selector:@selector(doSelectQuitGame)];
    
    // Create the menu
    optionsMenu = [CCMenu menuWithItems:nil];
    // Add menu items
    [optionsMenu addChild:resumeBtn];
    [optionsMenu addChild:restartBtn];
    [optionsMenu addChild:levelBtn];
    [optionsMenu addChild:quitBtn];
    
    // Add the menu to the layer
    [self addChild:optionsMenu z:19];
    // Position menu
    [optionsMenu alignItemsVerticallyWithPadding:5];
    [optionsMenuBack setPosition:ccp(wins.width/2,wins.height/2)];
    [optionsMenu setPosition:ccp(wins.width/2,wins.height/2)];
}

-(void) doCloseOptionsMenu {
    // Remove the menu from the layer and clean up
    [optionsMenuBack.parent removeChild:optionsMenuBack cleanup:YES];
    optionsMenuBack = nil;
    [optionsMenu.parent removeChild:optionsMenu cleanup:YES];
    optionsMenu = nil;
}


#pragma mark Options Menu Selector Methods
-(void) doSelectEndTurn{
    [_mainGame._theGame doEndTurn];
}

-(void) doSelectRestartLevel{
    [_mainGame._theGame doRestartLevel];
}

-(void) doSelectLevelSelect{
    [_mainGame._theGame doLevelSelect];
}

-(void) doSelectQuitGame{
    [_mainGame._theGame restartGame];
}

@end
