#import "Unit.h"
#import "SimpleAudioEngine.h"
#import "Building_Castle.h"
#import "Building_Barracks.h"
#import "GameLayer.h"
#import "HUDLayer.h"

//Import all units that can capture buildings, or change building capture code??
//#import "Unit_Footman.h"

#define kACTION_MOVEMENT 0
#define kACTION_ATTACK 1
#define kACTION_JOIN 2
#define kACTION_CAPTURE 3

extern int player1;
extern int player2;

@implementation Unit

@synthesize mainGame, theGame;
@synthesize mySprite, hpLabel;
@synthesize movementRange, attackRange, unitAtk, unitDef, unitCost, canAttack, canCapture, canJoin, isRanged, isHealer, owner;
@synthesize state, hp, moving, movedThisTurn, attackedThisTurn, selectingMovement,selectingAttack, selectingJoin;
@synthesize tileDataBeforeMovement, spOpenSteps, spClosedSteps, movementPath;

+(id)nodeWithTheGame:(GameLayer *)_theGame tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    // Dummy method - implemented in sub-classes
    return nil;
}

-(id)init {
    if ((self=[super init])) {
        state = kStateUngrabbed;
        
        spOpenSteps = [[NSMutableArray alloc] init];
        spClosedSteps = [[NSMutableArray alloc] init];
        movementPath = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Getters
// Can the unit walk over the given tile?
-(BOOL)canWalkOverTile:(TileData *)td {
    return YES;
}

-(double)getHP {
    return hp;
}

#pragma mark Create Unit
// Create the sprite and HP label for each unit
-(void)createSprite:(NSMutableDictionary *)tileDict {
    int x = [[tileDict valueForKey:@"x"] intValue]/[theGame spriteScale];
    int y = [[tileDict valueForKey:@"y"] intValue]/[theGame spriteScale];
    int width = [[tileDict valueForKey:@"width"] intValue]/[theGame spriteScale];
    int height = [[tileDict valueForKey:@"height"] intValue];
    int heightInTiles = height/[theGame getTileHeightForRetina];
    x += width/2;
    y += (heightInTiles * [theGame getTileHeightForRetina]/(2*[theGame spriteScale]));
    // Create building sprite and position it
    if (owner==1) {
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],player1]];
    }
    else if (owner==2) {
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],player2]];
    }
    if (owner==1) {
        mySprite.flipX=YES;
    }
    [self addChild:mySprite];
    mySprite.userData = self;
    mySprite.position = ccp(x,y);
    hpLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%ld",lroundf(hp/10)] fntFile:@"Font_dark_size12.fnt"];
    [mySprite addChild:hpLabel];
    [hpLabel setPosition:ccp([mySprite boundingBox].size.width-[hpLabel boundingBox].size.width/2,[hpLabel boundingBox].size.height/2)];
}

#pragma mark Unit Touch Handling

// Was this unit below the point that was touched?
-(BOOL)containsTouchLocation:(UITouch *)touch {
    if (CGRectContainsPoint([mySprite boundingBox], [self convertTouchToNodeSpaceAR:touch])) {
        return YES;
    }
    return NO;
}

// Handle touches
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (theGame.selectedBuilding) {
        return NO;
    }
    if (theGame.selectedUnit) {
        return NO;
    }
    // Was a unit belonging to the non-active player touched? If yes, do not handle the touch
    if ((([theGame.p1Units containsObject:self] && theGame._mainGame.playerTurn == 2) || ([theGame.p2Units containsObject:self] && theGame._mainGame.playerTurn == 1)))
        return NO;
    // If the action menu is showing, do not handle any touches on unit
    if (theGame.unitActionsMenu)
        return NO;
    if (theGame.buildingActionsMenu)
        return NO;
    // If the current unit is the selected unit, do not handle any touches
    if (theGame.selectedUnit == self)
        return NO;
    // If this unit has moved already, do not handle any touches
    if (movedThisTurn)
        return NO;
    if (state != kStateUngrabbed)
        return NO;
    if (![self containsTouchLocation:touch])
        return NO;
    state = kStateGrabbed;
    [theGame unselectUnit];
    [self selectUnit];
    return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    state = kStateUngrabbed;
}

-(void) onEnter {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

-(void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

// Select this unit
-(void)selectUnit {
    [theGame selectUnit:self];
    // Make the selected unit slightly bigger
    mySprite.scale = 1.1;
    // If the unit was not moved this turn, mark it as possible to move
    if (!movedThisTurn) {
        selectingMovement = YES;
        [self markPossibleAction:kACTION_MOVEMENT];
    }
}

// Deselect this unit
-(void)unselectUnit {
    // Reset the sprit back to normal size
    mySprite.scale = 1;
    selectingMovement = NO;
    selectingAttack = NO;
    [self unMarkPossibleMovement];
    [self unMarkPossibleAttack];
    [self unMarkPossibleJoin];
    [theGame.getController enableWithTouchPriority:3 swallowsTouches:YES];
}

#pragma mark Unit Menu Handling
// Carry out specified action for this unit
-(void)markPossibleAction:(int)action {
    [theGame.getController disable];
    
    // Get the tile where the unit is standing
    TileData *startTileData = [theGame getTileData:[theGame tileCoordForPosition:mySprite.position]];
    [spOpenSteps addObject:startTileData];
    [spClosedSteps addObject:startTileData];
    
    // If we are selecting movement, paint the tiles
    if (action == kACTION_MOVEMENT) {
        [theGame paintMovementTile:startTileData];
    } else if (action == kACTION_ATTACK && self.canAttack==true) {
        [theGame checkAttackTile:startTileData unitOwner:owner];
    } else if(action == kACTION_JOIN && self.canJoin==true) {
        [theGame checkJoinTile:startTileData unitOwner:owner joinerType:self];
    } else if(action ==kACTION_CAPTURE && self.canCapture==true) {
        [self doCapture];
    }
    int i =0;
    // For each tile in the list, beginning with the start tile
    do {
        TileData * _currentTile = ((TileData *)[spOpenSteps objectAtIndex:i]);
        // You get every 4 tiles surrounding the current tile
        NSMutableArray * tiles = [theGame getTilesNextToTile:_currentTile.position];
        for (NSValue * tileValue in tiles) {
            TileData * _neighbourTile = [theGame getTileData:[tileValue CGPointValue]];
            // If you already dealt with it, you ignore it.
            if ([spClosedSteps containsObject:_neighbourTile]) {
                // Ignore it
                continue;
            }
            // If there is an enemy on the tile and you are moving, ignore it. You can't move there.
            if (action == kACTION_MOVEMENT && [theGame otherEnemyUnitInTile:_neighbourTile unitOwner:owner]) {
                // Ignore it
                continue;
            }
            // If you are moving and this unit can't walk over that tile type, ignore it.
            if (action == kACTION_MOVEMENT && ![self canWalkOverTile:_neighbourTile]) {
                // Ignore it
                continue;
            }
            _neighbourTile.parentTile = nil;
            _neighbourTile.parentTile = _currentTile;

            if (action == kACTION_MOVEMENT) { // If you can move over there, paint it.
                [theGame paintMovementTile:_neighbourTile];
            } else if (action == kACTION_ATTACK) { //If you can attack it
                [theGame checkAttackTile:_neighbourTile unitOwner:owner];
            } else if (action == kACTION_JOIN) { //If you can join it
                [theGame checkJoinTile:_neighbourTile unitOwner:owner joinerType:self];
            }
            // Check how much it costs to move to or attack that tile.
            if (action == kACTION_MOVEMENT) {
                if ([_neighbourTile getGScore]> movementRange) {
                    continue;
                }
            } //else??
            if (action == kACTION_ATTACK) {
                // Is the tile not in attack range?
                if ([_neighbourTile getGScoreForAttack]> attackRange) {
                    // Ignore it
                    continue;
                }
            } //else??
            if (action == kACTION_JOIN) {
                // Is the tile not in join range?
                if ([_neighbourTile getGScoreForAttack]> 1) {
                    // Ignore it
                    continue;
                }
            }
            [spOpenSteps addObject:_neighbourTile];
            [spClosedSteps addObject:_neighbourTile];
        }
        i++;
    } while (i < [spOpenSteps count]);
    [spClosedSteps removeAllObjects];
    [spOpenSteps removeAllObjects];
}

// Cancel the move for the current unit and go back to previous position
-(void)doCancel {
    // Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    // Remove the context menu since we've taken an action
    [theGame removeUnitActionsMenu];
    // Move back to the previous tile
    mySprite.position = [theGame positionForTileCoord:tileDataBeforeMovement.position];
    [theGame unselectUnit];
}

#pragma mark Handling Movement

// Remove the "possible-to-move" indicator
-(void)unMarkPossibleMovement {
    for (TileData * td in theGame.tileDataArray) {
        [theGame unPaintMovementTile:td];
        td.parentTile = nil;
        td.selectedForMovement = NO;
    }
}

-(void)insertOrderedInOpenSteps:(TileData *)tile {
    // Compute the step's F score
    int tileFScore = [tile fScore];
    int count = [spOpenSteps count];
    // This will be the index at which we will insert the step
    int i = 0;
    for (; i < count; i++) {
        // If the step's F score is lower or equal to the step at index i
        if (tileFScore <= [[spOpenSteps objectAtIndex:i] fScore]) {
            // Then you found the index at which you have to insert the new step
            // Basically you want the list sorted by F score
            break;
        }
    }
    // Insert the new step at the determined index to preserve the F score ordering
    [spOpenSteps insertObject:tile atIndex:i];
}

-(int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord {
    // Here you use the Manhattan method, which calculates the total number of steps moved horizontally and vertically to reach the
    // final desired step from the current step, ignoring any obstacles that may be in the way
    return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

-(int)costToMoveFromTile:(TileData *)fromTile toAdjacentTile:(TileData *)toTile {
    // Because you can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
    // But it has to be different if you can move diagonally and/or if there are swamps, hills, etc...
    return 1;
}

-(void)constructPathAndStartAnimationFromStep:(TileData *)tile {
    [movementPath removeAllObjects];
    // Repeat until there are no more parents
    do {
        // Don't add the last step which is the start position (remember you go backward, so the last one is the origin position ;-)
        if (tile.parentTile != nil) {
            // Always insert at index 0 to reverse the path
            [movementPath insertObject:tile atIndex:0];
        }
        // Go backward
        tile = tile.parentTile;
    } while (tile != nil);
    [self popStepAndAnimate];
}

-(void)popStepAndAnimate {
    // Check if the unit is done moving
    if ([movementPath count] == 0) {
        // Mark the unit as not moving
        moving = NO;
        [self unMarkPossibleMovement];
        // Mark the tiles that can be attacked/joined
        [self markPossibleAction:kACTION_ATTACK];
        [self markPossibleAction:kACTION_JOIN];
        // Check for enemies in range
        BOOL enemiesAreInRange = NO;
        BOOL alliesAreInRange = NO;
        BOOL captureValid = NO;
        for (TileData *td in theGame.tileDataArray) {
            if (td.selectedForAttack) {
                NSLog(@"> Attack valid");
                enemiesAreInRange = YES;
                //alliesAreInRange = YES;
                break;
            } //else??
            if (td.selectedForJoin){
                NSLog(@"> Join valid");
                //enemiesAreInRange = YES;
                alliesAreInRange = YES;
                break;
            }
        }
        Building *buildingBelow = [theGame buildingInTile:[theGame getTileData:[theGame tileCoordForPosition:mySprite.position]]];
        if (buildingBelow && (buildingBelow.class==Building_Castle.class||buildingBelow.class==Building_Barracks.class) && buildingBelow.owner!=self.owner) {
            captureValid=YES;
        }
        
        //Show the menu and enable the Attack option if there are enemies/allies in range
        [theGame showUnitActionsMenu:self canAttack:enemiesAreInRange canJoin:alliesAreInRange canCapture:captureValid];
        return;
    }
    
    // Play move sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.wav"];
    
    // Get the next step to move toward
    TileData *s = [movementPath objectAtIndex:0];
    // Prepare the action and the callback
    id moveAction = [CCMoveTo actionWithDuration:0.2 position:[theGame positionForTileCoord:s.position]];
    // set the method itself as the callback
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)];
    // Remove the step
    [movementPath removeObjectAtIndex:0];
    // Play actions
    [mySprite runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}

-(void)doMarkedMovement:(TileData *)targetTileData {
    if (moving)
        return;
    moving = YES;
    CGPoint startTile = [theGame tileCoordForPosition:mySprite.position];
    tileDataBeforeMovement = [theGame getTileData:startTile];
    [self insertOrderedInOpenSteps:tileDataBeforeMovement];
    do {
        TileData * _currentTile = ((TileData *)[spOpenSteps objectAtIndex:0]);
        CGPoint _currentTileCoord = _currentTile.position;
        [spClosedSteps addObject:_currentTile];
        [spOpenSteps removeObjectAtIndex:0];
        // If the currentStep is the desired tile coordinate, you are done!
        if (CGPointEqualToPoint(_currentTile.position, targetTileData.position)) {
            [self constructPathAndStartAnimationFromStep:_currentTile];
            // Set to nil to release unused memory
            [spOpenSteps removeAllObjects];
            // Set to nil to release unused memory
            [spClosedSteps removeAllObjects];
            break;
        }
        NSMutableArray * tiles = [theGame getTilesNextToTile:_currentTileCoord];
        for (NSValue * tileValue in tiles) {
            CGPoint tileCoord = [tileValue CGPointValue];
            TileData * _neighbourTile = [theGame getTileData:tileCoord];
            if ([spClosedSteps containsObject:_neighbourTile]) {
                continue;
            }
            if ([theGame otherEnemyUnitInTile:_neighbourTile unitOwner:owner]) {
                // Ignore it
                continue;
            }
            if (![self canWalkOverTile:_neighbourTile]) {
                // Ignore it
                continue;
            }
            int moveCost = [self costToMoveFromTile:_currentTile toAdjacentTile:_neighbourTile];
            NSUInteger index = [spOpenSteps indexOfObject:_neighbourTile];
            if (index == NSNotFound) {
                _neighbourTile.parentTile = nil;
                _neighbourTile.parentTile = _currentTile;
                _neighbourTile.gScore = _currentTile.gScore + moveCost;
                _neighbourTile.hScore = [self computeHScoreFromCoord:_neighbourTile.position toCoord:targetTileData.position];
                [self insertOrderedInOpenSteps:_neighbourTile];
            } else {
                // To retrieve the old one (which has its scores already computed ;-)
                _neighbourTile = [spOpenSteps objectAtIndex:index];
                // Check to see if the G score for that step is lower if you use the current step to get there
                if ((_currentTile.gScore + moveCost) < _neighbourTile.gScore) {
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    _neighbourTile.gScore = _currentTile.gScore + moveCost;
                    // Now you can remove it from the list without being afraid that it can't be released
                    [spOpenSteps removeObjectAtIndex:index];
                    // Re-insert it with the function, which is preserving the list ordered by F score
                    [self insertOrderedInOpenSteps:_neighbourTile];
                }
            }
        }
    } while ([spOpenSteps count]>0);
}

// Stay on the current tile
-(void)doStay {
    // Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    //Maintenance
    [theGame removeUnitActionsMenu];
    movedThisTurn = YES;
    
    //Turn the unit grey showing resting
    [mySprite setColor:ccGRAY];
    [theGame unselectUnit];
}

#pragma mark Handling Capturing
-(void) doCapture {
    //Stay unit first
    [self doStay];
    
    //Then make changes to buildings
    Building *buildingBelow = [theGame buildingInTile:[theGame getTileData:[theGame tileCoordForPosition:mySprite.position]]];
    
    if (buildingBelow.owner != self.owner && self.canCapture==true) {
        if (buildingBelow && buildingBelow.class==Building_Castle.class) { // There can only be one castle
            // Show end game message
            [theGame showEndGameMessageWithWinner:self.owner];
        } else if (buildingBelow && buildingBelow.class==Building_Barracks.class) {
            // Unit destroyed sound
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
            
            [buildingBelow.parent removeChild:buildingBelow cleanup:YES];
            if ([theGame.p1Buildings containsObject:buildingBelow]) {
                [theGame.p1Buildings removeObject:buildingBelow];
            } else if ([theGame.p2Buildings containsObject:buildingBelow]) {
                [theGame.p2Buildings removeObject:buildingBelow];
            } else if ([theGame.eBuildings containsObject:buildingBelow]) {
                [theGame.eBuildings removeObject:buildingBelow];
            }
            
            [self createCapturedBuilding:@"Barracks"];
            
        }
    }
}

-(void)createCapturedBuilding:(NSString *)buildingType {
    //pass desired unit to it and make that unit
    NSMutableArray * buildings = nil;
    if (theGame._mainGame.playerTurn ==1){
        buildings = theGame.p1Buildings;
    } else if (theGame._mainGame.playerTurn ==2){
        buildings = theGame.p2Buildings;
    }
    
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    [d setObject:(@"%@", buildingType) forKey:@"Type"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"%f", (mySprite.position.x-16)*2]) forKey:@"x"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"%f", (mySprite.position.y-16)*2]) forKey:@"y"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"64"]) forKey:@"height"];
    [d setObject:(@"%@", [NSString stringWithFormat:@"64"]) forKey:@"width"];
    NSString *classNameStr = [NSString stringWithFormat:@"Building_%@",buildingType];
    Class theClass = NSClassFromString(classNameStr);
    
    Building *building = [theClass nodeWithTheGame:theGame tileDict:[NSMutableDictionary dictionaryWithDictionary:d] owner:theGame._mainGame.playerTurn];
    [buildings addObject:building];
    //[unit setPosition:ccp(mySprite.position.x,mySprite.position.y)];
    
}

#pragma mark Handling Healing
-(void) doHealing1 {
    if (hp==100) {
    }
    else{
        hp +=30;
        if (hp>100) {
            hp=100;
        }
        CCSprite *healing = [CCSprite spriteWithFile:@"heal_1.png"];
        [self addChild:healing z:10];
        CCAnimation *healAnimation = [CCAnimation animation];
        for (int i=1;i<=8;i++) {
            [healAnimation addSpriteFrameWithFilename: [NSString stringWithFormat:@"heal_%d.png", i]];
        }
        id healAction = [CCAnimate actionWithDuration:0.5 animation:healAnimation restoreOriginalFrame:NO];
        
        [healing setPosition:mySprite.position];
        [[SimpleAudioEngine sharedEngine] playEffect:@"hurt.wav"];
        [healing runAction: [CCSequence actions: healAction,
                             [CCCallFuncN actionWithTarget:self selector:@selector(removeHealingAnimation:)],
                             nil]];
    }
    [self updateHpLabel];
}

-(void) doHealing2 {
    if (self.owner == theGame._mainGame.playerTurn){
        if (hp==100) {
        }
        else{
            hp +=10;
            if (hp>100) {
                hp=100;
            }
            CCSprite *healing = [CCSprite spriteWithFile:@"heal_1.png"];
            [self addChild:healing z:10];
            CCAnimation *healAnimation = [CCAnimation animation];
            for (int i=1;i<=8;i++) {
                [healAnimation addSpriteFrameWithFilename: [NSString stringWithFormat:@"heal_%d.png", i]];
            }
            id healAction = [CCAnimate actionWithDuration:0.5 animation:healAnimation restoreOriginalFrame:NO];
        
            [healing setPosition:mySprite.position];
            [[SimpleAudioEngine sharedEngine] playEffect:@"hurt.wav"];
            [healing runAction: [CCSequence actions: healAction,
                             [CCCallFuncN actionWithTarget:self selector:@selector(removeHealingAnimation:)],
                             nil]];
        }
    [self updateHpLabel];
    }
}

#pragma mark Handling Attacks
// Attack another unit
-(void)doAttack {
    // Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    //Remove the menu
    [theGame removeUnitActionsMenu];
    //Check if any tile has been selected for attack
    for (TileData *td in theGame.tileDataArray) {
        if (td.selectedForAttack) {
            //Mark the selected tile as attackable
            [theGame paintAttackTile:td];
        }
    }
    selectingAttack = YES;
}

// Remove attack selection marking from all tiles
-(void)unMarkPossibleAttack {
    for (TileData *td in theGame.tileDataArray) {
        [theGame unPaintAttackTile:td];
        td.parentTile = nil;
        td.selectedForAttack = NO;
    }
}

// Attack the specified tile
-(void)doMarkedAttack:(TileData *)targetTileData {
    // Mark the unit as having attacked this turn
    attackedThisTurn = YES;
    // Get the attacked unit
    Unit *attackedUnit = [theGame otherEnemyUnitInTile:targetTileData unitOwner:owner];
    // Let the attacked unit handle the attack
    [attackedUnit attackedBy:self firstAttack:YES];
    // Keep this unit in the current location
    [self doStay];
}

// Handle the attack from another unit
-(void)attackedBy:(Unit *)attacker firstAttack:(BOOL)firstAttack {
    // Create the damage data since we need to pass this information on to another method
    NSMutableDictionary *damageData = [NSMutableDictionary dictionaryWithCapacity:2];
    [damageData setObject:attacker forKey:@"attacker"];
    [damageData setObject:[NSNumber numberWithBool:firstAttack] forKey:@"firstAttack"];
    // Create explosion sprite
    CCSprite *explosion = [CCSprite spriteWithFile:@"explosion_1.png"];
    [self addChild:explosion z:10];
    [explosion setPosition:mySprite.position];
    // Create explosion animation
    CCAnimation *animation = [CCAnimation animation];
    for (int i=1;i<=7;i++) {
        [animation addSpriteFrameWithFilename: [NSString stringWithFormat:@"explosion_%d.png", i]];
    }
    id action = [CCAnimate actionWithDuration:0.5 animation:animation restoreOriginalFrame:NO];
    //CCAnimation::setDelayPerUnit(float)
    //http://cocos2d-x.org/forums/6/topics/13469?r=13526
    
    // Run the explosion animation, call method to remove explosion once it's done and finally calculate damage from attack
    // Play damage sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"hurt.wav"];
    [explosion runAction: [CCSequence actions: action,
                           [CCCallFuncN actionWithTarget:self selector:@selector(removeExplosion:)],
                           [CCCallFuncO actionWithTarget:self selector:@selector(dealDamage:) object:damageData],
                           nil]];
}

// Calculate damage from attack
-(void)dealDamage:(NSMutableDictionary *)damageData {
    // Get the attacker from the passed in data dictionary
    Unit *attacker = [damageData objectForKey:@"attacker"];

    // Calculate damage
    hp -= [theGame calculateDamageFrom:attacker onDefender:self];
    // Is the unit dead?
    if (hp<5) {
        //Unit is dead - remove it from game
        [self.parent removeChild:self cleanup:YES];
        // Unit destroyed sound
        [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
    
        if ([theGame.p1Units containsObject:self]) {
            [theGame.p1Units removeObject:self];
        } else if ([theGame.p2Units containsObject:self]) {
            [theGame.p2Units removeObject:self];
        }
        [theGame checkForMoreUnits];
    } else {
        [self updateHpLabel];
        // Call attackedBy: on the attacker so that damage can be calculated for the attacker
        // Check whether the attacked unit can respond
        if (attacker.isRanged==true) {
            //do nothing
        }
        else{
            //attack back
            if ([[damageData objectForKey:@"firstAttack"] boolValue] && !attacker.isRanged) {
                [attacker attackedBy:self firstAttack:NO];
            }
        }
    }
}

#pragma mark Handling Joining other units
-(void)doJoin {
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    [theGame removeUnitActionsMenu];
    //Check if any tile has been selected for attack
    for (TileData *td in theGame.tileDataArray) {
        if (td.selectedForJoin) {
            //Mark the selected tile as joinable
            [theGame paintAttackTile:td]; //Should this be paintAttackTile???
        }
    }
    selectingJoin = YES;
}

// Remove attack selection marking from all tiles
-(void)unMarkPossibleJoin {
    for (TileData *td in theGame.tileDataArray) {
        [theGame unPaintAttackTile:td];
        td.parentTile = nil;
        td.selectedForJoin = NO;
    }
}

// Attack the specified tile
-(void)doMarkedJoin:(TileData *)targetTileData {
    // Mark the unit as having attacked this turn
    attackedThisTurn = YES;
    // Get the attacked unit
    Unit *joinedUnit = [theGame otherJoinableUnitInTile:targetTileData unitOwner:owner unitType:self];
    // Let the attacked unit handle the attack
    [joinedUnit joinedBy:self joining:joinedUnit];
    // Keep this unit in the current location
    [joinedUnit doStay];
}

// Handle the attack from another unit
-(void)joinedBy:(Unit *)joiner joining:(Unit *)target{
    // Create the damage data since we need to pass this information on to another method
    //JoiningData = contains joiner
    //Joiner = The person joining - to be deleted
    
    NSMutableDictionary *joiningData = [NSMutableDictionary dictionaryWithCapacity:2];
    [joiningData setObject:joiner forKey:@"joiner"];
    [joiningData setObject:target forKey:@"target"];
    
    CCSprite *healing = [CCSprite spriteWithFile:@"heal_1.png"];
    [self addChild:healing z:10];
    [healing setPosition:mySprite.position];
    CCAnimation *healAnimation = [CCAnimation animation];
    for (int i=1;i<=7;i++) {
        [healAnimation addSpriteFrameWithFilename: [NSString stringWithFormat:@"heal_%d.png", i]];
    }
    id healAction = [CCAnimate actionWithDuration:0.5 animation:healAnimation restoreOriginalFrame:NO];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"hurt.wav"];
    [healing runAction: [CCSequence actions: healAction,
                         [CCCallFuncN actionWithTarget:self selector:@selector(removeHealingAnimation:)],
                         [CCCallFuncO actionWithTarget:self selector:@selector(join:) object:joiningData],
                         nil]];
}

-(void)join:(NSMutableDictionary *)joiningData {
    // Get the attacker from the passed in data dictionary
    Unit *joiner = [joiningData objectForKey:@"joiner"];
    //Unit *target = [joiningData objectForKey:@"target"];
    
    // Calculate new health
    hp += joiner.getHP;
    
    //Joiner is removed from game
    [joiner.parent removeChild:joiner cleanup:YES];
    
    if ([theGame.p1Units containsObject:joiner]) {
        [theGame.p1Units removeObject:joiner];
    } else if ([theGame.p2Units containsObject:joiner]) {
        [theGame.p2Units removeObject:joiner];
    }
    if (self.getHP>100) {
        hp=100;
    }
    [theGame checkForMoreUnits];
    [self updateHpLabel];
}

#pragma mark Maintenance
// Activate this unit for play
-(void)startTurn {
    // Mark the unit as not having moved for this turn
    movedThisTurn = NO;
    // Mark the unit as not having attacked this turn
    attackedThisTurn = NO;
    // Change the unit overlay colour from gray (inactive) to white (active)
    [mySprite setColor:ccWHITE];
}

// Update the HP value display
-(void) updateHpLabel {
    [hpLabel setString:[NSString stringWithFormat:@"%ld",lroundf(hp/10)]];
    [hpLabel setPosition:ccp([mySprite boundingBox].size.width-[hpLabel boundingBox].size.width/2,[hpLabel boundingBox].size.height/2)];
    
    //NSLog(@"Health: %ld (%f)", lroundf(hp/10), hp);
}

// Clean up after explosion
-(void)removeExplosion:(CCSprite *)e {
    // Remove the explosion sprite
    [e.parent removeChild:e cleanup:YES];
}

//Clean up after healing
-(void) removeHealingAnimation:(CCSprite *)e {
    // Remove the explosion sprite
    [e.parent removeChild:e cleanup:YES];
}

#pragma mark dealloc
-(void)dealloc {
    
    [movementPath release];
    movementPath = nil;
    [spOpenSteps release];
    spOpenSteps = nil;
    [spClosedSteps release];
    spClosedSteps = nil;
    
    [super dealloc];
}

@end