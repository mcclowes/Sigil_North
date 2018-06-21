//
//  Building.m
//  Sigil North
//
//  Created by M F J C Clowes on 17/11/2012.
//  Copyright 2012 __Digistar Ltd__. All rights reserved.
//

#import "Building.h"
#import "SimpleAudioEngine.h"
#import "MainGameLayer.h"
#import "GameLayer.h"
#import "HUDLayer.h"
#import "Unit.h"

#define kACTION_HIRE 0

extern int player1;
extern int player2;
extern int environment;

@implementation Building

@synthesize mainGame, theGame;
@synthesize mySprite, captureLabel;
@synthesize buildingDefBonus, canHeal, canHireUnits, canGenerateMoney, owner;
@synthesize captureLevel, selectingUnit, hiringUnit, hiredThisTurn, state;

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    // Dummy method - implemented in sub-classes
    return nil;
}

-(id)init {
    if ((self=[super init])) {
    state = kStateUngrabbed;

    }
    return self;
}

#pragma mark Getters
-(BOOL)getCanHeal {
    return canHeal;
}

-(BOOL)getCanHireUnits {
    return canHireUnits;
}

#pragma mark Create Building
-(void)createSprite:(NSMutableDictionary *)tileDict {
    // Get the sprite position and dimension from tile data
    int x = [[tileDict valueForKey:@"x"] intValue]/[theGame spriteScale];
    int y = [[tileDict valueForKey:@"y"] intValue]/[theGame spriteScale];
    int width = [[tileDict valueForKey:@"width"] intValue]/[theGame spriteScale];
    int height = [[tileDict valueForKey:@"height"] intValue];
    
    // Get the height of the building in tiles
    int heightInTiles = height/[theGame getTileHeightForRetina];
    
    // Calculate x and y values
    x += width/2;
    y += (heightInTiles * [theGame getTileHeightForRetina]/(2*[theGame spriteScale]));
    
    // Create building sprite and position it
    if (owner==1) {
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],player1]];
    } else if (owner==2) {
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],player2]];
    } else if (owner==5) {
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],environment]];
    }
    
    [self addChild:mySprite];
    mySprite.userData = self;
    mySprite.position = ccp(x,y);
}

#pragma mark Building Touch Handling
-(void)onEnter {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

-(void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

// Was this unit below the point that was touched?
-(BOOL)containsTouchLocation:(UITouch *)touch {
    if (CGRectContainsPoint([mySprite boundingBox], [self convertTouchToNodeSpaceAR:touch])) {
        return YES;
    }
    return NO;
}

// Handle touches
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //If a building is being moved, ignore touch
    if (theGame.selectedBuilding) {
        return NO;
    }
    if (theGame.selectedUnit) {
        return NO;
    }
    Unit *unitAbove = [theGame unitInTile:[theGame getTileData:[theGame tileCoordForPosition:mySprite.position]]];
    if (unitAbove) {
        return NO;
    }
    // Building belongs to player
    if (([theGame.p1Buildings containsObject:self] && theGame._mainGame.playerTurn == 2) || ([theGame.p2Buildings containsObject:self] && theGame._mainGame.playerTurn == 1))
        return NO;
    // If the action menu is showing, do not handle any touches on unit
    if (theGame.buildingActionsMenu)
        return NO;
    if (theGame.unitActionsMenu)
        return NO;
    // If the current unit is the selected unit, do not handle any touches
    if (theGame.selectedBuilding == self)
        return NO;
    // If this unit has moved already, do not handle any touches
    if (hiredThisTurn)
        return NO;
    if (state != kStateUngrabbed)
        return NO;
    if (![self containsTouchLocation:touch])
        return NO;
    state = kStateGrabbed;
    [theGame unselectBuilding];
    [self selectBuilding];
    return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    state = kStateUngrabbed;
}

// Select this unit
-(void)selectBuilding {
    [theGame selectBuilding:self];
    // Make the selected unit slightly bigger
    mySprite.scale = 1.1;
    hiredThisTurn = NO;
    // If the building has not hired this turn, mark it as possible to hire
    if (!hiredThisTurn) {
        hiringUnit = YES;
        //[self markBuildingAction:kACTION_HIRE];
        
    }
    if (canHireUnits==false) {
        [self unselectBuilding];
        theGame.selectedBuilding=nil;
    } else {
        [theGame showBuildingActionsMenu:self canHireUnit:canHireUnits];
    }
}

// Deselect this unit
-(void)unselectBuilding {
    // Reset the sprit back to normal size
    mySprite.scale =1;
    hiringUnit = NO;
}

// Cancel the move for the current unit and go back to previous position
-(void)doCancel {
    // Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    // Remove the context menu since we've taken an action
    [theGame removeBuildingActionsMenu];
    [theGame unselectBuilding];
}

#pragma mark Hiring Handling

-(void)hireFootman{
    [self createHiredUnit: @"Footman"];
}
-(void)hireCenturion{
    [self createHiredUnit: @"Centurion"];
}
-(void)hireRanger{
    [self createHiredUnit: @"Ranger"];
}
-(void)hireBattleMage{
    [self createHiredUnit: @"BattleMage"];
}
-(void)hirePriest{
    [self createHiredUnit: @"Priest"];
}

-(void)createHiredUnit:(NSString *)unitType {
    //pass desired unit to it and make that unit
    NSMutableArray * units = nil;
    if (theGame._mainGame.playerTurn ==1){
        units = theGame.p1Units;
    } else if (theGame._mainGame.playerTurn ==2){
        units = theGame.p2Units;
    }
    
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    [d setObject:(@"%@", unitType) forKey:@"Type"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"%f", (mySprite.position.x-16)*2]) forKey:@"x"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"%f", (mySprite.position.y-16)*2]) forKey:@"y"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"64"]) forKey:@"height"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"64"]) forKey:@"width"];
    NSString *classNameStr = [NSString stringWithFormat:@"Unit_%@",unitType];
    Class theClass = NSClassFromString(classNameStr);
    
    Unit * unit = [theClass nodeWithTheGame:theGame tileDict:[NSMutableDictionary dictionaryWithDictionary:d] owner:theGame._mainGame.playerTurn];
    
    //Qualifiers for building
    //This is inelegant
    if (theGame._mainGame.playerTurn==1) {
        if (theGame._mainGame.player1Gold-unit.unitCost>=0) {
            theGame._mainGame.player1Gold-=unit.unitCost;
            [theGame updateMoneyLabel];
            hiredThisTurn=true;
            hiringUnit=false;
        }
        else {
            [theGame removeChild:unit cleanup:YES];
            [theGame.p1Units removeObject:self];
            return;
        }
    } else if (theGame._mainGame.playerTurn==2){
        if (theGame._mainGame.player2Gold-unit.unitCost>=0) {
            theGame._mainGame.player2Gold-=unit.unitCost;
            [theGame updateMoneyLabel];
            hiredThisTurn=true;
            hiringUnit=false;
        }
        else {
            [theGame removeChild:unit cleanup:YES];
            [theGame.p2Units removeObject:self];
            return;
        }
    }
    
    //Continue
    [unit doStay];
    [units addObject:unit];
    //[unit setPosition:ccp(mySprite.position.x,mySprite.position.y)];
    [self doFinishHiring];

}

-(void)doFinishHiring {
    // Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    // Remove menu
    [theGame removeBuildingActionsMenu];
    hiredThisTurn = YES;
    
    // Turn the building grey showing resting
    [mySprite setColor:ccGRAY];
    [theGame unselectBuilding];
}

#pragma mark Capture Handling
-(void)createCaptureLabel{
    //fill in
}

#pragma mark Maintenance
// Activate this unit for play
-(void)startTurn {
    // Mark the unit as not having moved for this turn
    hiredThisTurn = NO;
    // Change the unit overlay colour from gray (inactive) to white (active)
    [mySprite setColor:ccWHITE];
}

-(void)updateCaptureLabel {
    //This needs to move - must be created when capturing begins
    //Must also be destroyed if the unit stop capturing/ is destroyed/etc
    [captureLabel setString:[NSString stringWithFormat:@"%ld",lroundf(captureLevel/10)]];
    [captureLabel setPosition:ccp([mySprite boundingBox].size.width-[captureLabel boundingBox].size.width/2,[captureLabel boundingBox].size.height/2)];
    
    NSLog(@"%ld", lroundf(captureLevel/10));
    NSLog(@"%f", captureLevel);
    
    //if capture level returns to 0/ the unit leaves, remove
}

#pragma mark dealloc
-(void)dealloc {
    //What??
    [super dealloc];
}



@end