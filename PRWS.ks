//GUI SCRIPT BASED ON A-EVAN-S's AND SCARECR-W's SCRIPT - " https://github.com/scarecr-w/kOS-Guided-Missile-System/blob/master/boot/MISSILE_SYSTEM.ks "

@lazyGlobal on.
//wait 2.
set terminal:width to 125.
set terminal:height to 40.
clearScreen.
print "                                         ______                ____           ______                                     ".
print "              |`````````, |`````````,  .~      ~.           | |             .~      ~. `````|`````                       ".
print "              |'''''''''  |'''|'''''  |          |          | |______      |                |                            ".
//wait 0.5.
print "              |           |    `.     |          | .        | |            |                |                            ".
print "              |           |      `.    `.______.'  `..____..' |___________  `.______.'      |                            ".
print "                                                                                                                         ".
//wait 0.5.
print "|`````````, |            `.           .' |            |              .'.       `````|````` |  .~      ~.  |..          | ".
print "|'''|'''''  |______        `.       .'   |______      |            .''```.          |      | |          | |  ``..      | ".
print "|    `.     |                `.   .'     |            |          .'       `.        |      | |          | |      ``..  | ".
//wait 0.5.
print "|      `.   |___________       `.'       |___________ |_______ .'           `.      |      |  `.______.'  |          ``| ".
print "                                                                                                                         ".
//wait 2.
print "initialization ." at(0,15).
//wait 0.5.
print "initialization .." at(0,15).
//wait 0.5.
print "initialization ..." at(0,15).
//wait 0.5.
print "                  " at(0,15).
print "initialization ." at(0,15).
//wait 0.5.
print "initialization .." at(0,15).
//wait 1.
clearScreen.
GLOBAL FIRED IS LIST().
GLOBAL MISSILES IS LIST().
function main {
    windowgui().
    GLOBAL TARGET_LOCKED IS FALSE.
    GLOBAL WEAPONS_SYSTEM_STOPPED IS FALSE.
    IF WEAPONS_SYSTEM_STOPPED {PRWS:HIDE().}
}
function windowgui{
    set PRWS to GUI(350).
    set PRWS:X to 100.
    set PRWS:Y to 100.

    LOCAL TITLE_LAYOUT IS PRWS:ADDHLAYOUT().
    TITLE_LAYOUT:ADDSPACING(15).
    LOCAL MAIN_TITLE IS TITLE_LAYOUT:ADDLABEL("<B>Project Revelation Weapon System</B>").
    SET MAIN_TITLE:STYLE:ALIGN TO "CENTER".
    SET MAIN_TITLE:STYLE:FONTSIZE TO 15.
    SET MAIN_TITLE:STYLE:FONT TO "OCR B MT".

    LOCAL CLOSE_BUTTON IS TITLE_LAYOUT:ADDBUTTON("<COLOR=RED> X</COLOR>").
    SET CLOSE_BUTTON:STYLE:WIDTH TO 25.
    SET CLOSE_BUTTON:STYLE:ALIGN TO "CENTER".
    SET CLOSE_BUTTON:ONCLICK TO {
        SET WEAPONS_SYSTEM_STOPPED TO TRUE.
    }.

    PRWS:ADDLABEL("MASTER ARM").
    LOCAL MASTER_ARM_BOX IS PRWS:ADDVBOX().

    LOCAL ARM_BUTTON IS MASTER_ARM_BOX:ADDVLAYOUT().
    SET ARM_BUTTON:STYLE:HEIGHT TO 25.
    LOCAL ARM_BOX_LAYOUT IS ARM_BUTTON:ADDHLAYOUT().
    ARM_BOX_LAYOUT:ADDSPACING(10).
    LOCAL ARM_BUTTON IS ARM_BOX_LAYOUT:ADDRADIOBUTTON("ARM").
    SET ARM_BUTTON:STYLE:WIDTH TO 100.
    LOCAL DISARM_BUTTON IS ARM_BOX_LAYOUT:ADDRADIOBUTTON("DISARM", TRUE).
    SET ARM_BOX_LAYOUT:ONRADIOCHANGE TO {
        DECLARE PARAMETER STATE.
        IF STATE:TEXT = "ARM" {
            clearScreen.
            Print "Arm".
            GLOBAL MASTERARM IS TRUE.
        } ELSE {
            clearScreen.
            Print "Disarm".
            GLOBAL MASTERARM IS FALSE.
        }
    }.

    PRWS:ADDLABEL("MISSILES").

    LOCAL MISSILE_SECTION IS PRWS:ADDVBOX().
    MISSILE_SECTION:ADDSPACING(5).
    LOCAL MISSILE_SECTION_MAIN IS MISSILE_SECTION:ADDHLAYOUT().
    LOCAL MISSILE_BOX IS MISSILE_SECTION_MAIN:ADDVLAYOUT().
    GLOBAL MISSILE_INFO_BOX IS MISSILE_SECTION_MAIN:ADDVBOX().
    SET MISSILE_INFO_BOX:STYLE:WIDTH TO 220.
    GLOBAL MISSILE_BOX_LAYOUT IS MISSILE_BOX:ADDVLAYOUT().
    LOCAL NONE_BUTTON IS MISSILE_BOX_LAYOUT:ADDRADIOBUTTON("NONE", TRUE).
    FOR I IN RANGE(MISSILES:LENGTH) {
        LOCAL MISSILE_SELECTION IS MISSILE_BOX_LAYOUT:ADDRADIOBUTTON("MISSILE " + (I+1), FALSE).
        SET MISSILE_SELECTION:ONCLICK TO SELECT_MISSILE@.
    }
    SET MISSILE_BOX_LAYOUT:ONRADIOCHANGE TO {
        DECLARE PARAMETER SELECTED_BUTTON.
        SETUP_MISSILE_INFO(SELECTED_BUTTON:TEXT).
    }.
    LOCAL FIRE_BUTTON_LAYOUT IS PRWS:ADDHLAYOUT().
    FIRE_BUTTON_LAYOUT:ADDSPACING(70).
    LOCAL FIRE_BUTTON IS FIRE_BUTTON_LAYOUT:ADDBUTTON("<COLOR=RED>FIRE</COLOR>").
    SET FIRE_BUTTON:STYLE:WIDTH TO 200.
    SET FIRE_BUTTON:ONCLICK TO {
        IF MISSILE_BOX_LAYOUT:RADIOVALUE <> "NONE" {
            LOCAL MISSILE_TEXT IS MISSILE_BOX_LAYOUT:RADIOVALUE:SPLIT(" ").
            LOCAL MISSILE_NUMBER IS MISSILE_TEXT[MISSILE_TEXT:LENGTH - 1]:TONUMBER().
            FIRE_MISSILE(MISSILES[MISSILE_NUMBER - 1]).
        }
    }.
    SETUP_MISSILE_INFO(NONE_BUTTON:TEXT).
    PRWS:SHOW().
}
FUNCTION SETUP_MISSILE_INFO {
    DECLARE PARAMETER SELECTION.
    MISSILE_INFO_BOX:CLEAR().
    LOCAL MISSILE_INFO_LABEL IS MISSILE_INFO_BOX:ADDLABEL("MISSILE INFO").
    SET MISSILE_INFO_LABEL:STYLE:ALIGN TO "CENTER".
    IF SELECTION <> "NONE" {
        LOCAL MISSILE_TEXT IS SELECTION:SPLIT(" ").
        LOCAL MISSILE_NUMBER IS MISSILE_TEXT[MISSILE_TEXT:LENGTH - 1]:TONUMBER() - 1.
        LOCAL MISSILE_STATUS IS CHOOSE "LAUNCHED" IF FIRED[MISSILE_NUMBER] ELSE "READY".
        LOCAL MISSILE_INFO_ONE IS MISSILE_INFO_BOX:ADDHLAYOUT().
        MISSILE_INFO_ONE:ADDLABEL("STATUS:").
        MISSILE_INFO_ONE:ADDLABEL(MISSILE_STATUS).
    } ELSE {
        LOCAL NO_MISSILE_LABEL IS MISSILE_INFO_BOX:ADDLABEL("NO MISSILE SELECTED").
        SET NO_MISSILE_LABEL:STYLE:ALIGN TO "CENTER".
    }
}
FUNCTION ID_MISSILES {
    LIST PROCESSORS IN ALL_PROCESSORS.
    FOR PROCESSOR IN ALL_PROCESSORS {
        IF PROCESSOR:TAG = "SealFRST" {
            MISSILES:ADD(PROCESSOR).
            FIRED:ADD(FALSE).
            LOCAL MISSILE_BODY IS GET_MISSILE_BODY(PROCESSOR).
            MISSILE_BODIES:ADD(MISSILE_BODY).
            SET MISSILE_HIGHLIGHT TO HIGHLIGHT(MISSILE_BODY, RGB(1.0,0.0,0.0)).
            SET MISSILE_HIGHLIGHT:ENABLED TO FALSE.
            MISSILE_HIGHLIGHTS:ADD(MISSILE_HIGHLIGHT).
        }
    }
}

FUNCTION GET_MISSILE_BODY {
    DECLARE PARAMETER PROCESSOR.
    LOCAL DECOUPLER IS PROCESSOR:PART:DECOUPLER.
    LOCAL MISSILE_BODY IS LIST().
    LOCAL Q IS QUEUE().
    Q:PUSH(DECOUPLER:CHILDREN[0]).
    UNTIL Q:EMPTY {
        SET CURRENT_PART TO Q:POP().
        MISSILE_BODY:ADD(CURRENT_PART).
        FOR P IN CURRENT_PART:CHILDREN {
            Q:PUSH(P).
        }
    }
    RETURN MISSILE_BODY.
}

FUNCTION FIRE_MISSILE {
    DECLARE PARAMETER MISSILE.
    SET MISSILE_HIGHLIGHTS[MISSILES:FIND(MISSILE)]:ENABLED TO FALSE.
    LOCAL MISSILE_CONNECTION IS MISSILE:CONNECTION.
    IF MISSILE:CONNECTION:SENDMESSAGE(TARGET_INFO) and MASTERARM {
        PRINT "MISSILE FIRED".
        SET FIRED[MISSILES:FIND(MISSILE)] TO TRUE.
        SETUP_MISSILE_INFO(MISSILE_BOX_LAYOUT:RADIOVALUE).
    } ELSE {
        PRINT "FIRING FAILED".
    }
}

main().