#ifndef GUI_DEFINES_HPP
#define GUI_DEFINES_HPP

#include "includes\definecommoncolors.inc"
#include "includes\definecommongrids.inc"
#include "includes\definedikcodes.inc"
#include "includes\defineresincldesign.inc"
#include "includes\resincl.inc"

#define PIXELW_SCALED(SCALE) (pixelW * pixelGrid * SCALE)
#define PIXELH_SCALED(SCALE) (pixelH * pixelGrid * SCALE)
#define h_PIXELW PIXELW_SCALED(0.5)
#define h_PIXELH PIXELH_SCALED(0.5)

#define IDC_DISPLAY3DENEDITATTRIBUTES_VALUE 100

//Presets Display
#define PRESETS 10003
#define PRESETS_TITLE 100031
#define PRESETS_VALUE 100032
#define PRESETS_EDIT 100033
#define PRESETS_CLOSE 100034
#define PRESETS_LOAD 100035
#define PRESETS_SAVE 100036
#define PRESETS_DELETE 100037
#define PRESETS_MENU PRESETS

//Two-List Controls Group
#define LIST_MAIN 10000

#define LIST_1 10001
#define PRESETS_BTN 100011
#define TITLE_1 IDC_DISPLAY3DENEDITATTRIBUTES_TITLE
#define EDIT_1 100013
#define BUTTON_1 100014
#define BUTTON_2 100015
#define VALUE_1 IDC_DISPLAY3DENEDITATTRIBUTES_VALUE

#define LIST_2 10002
#define TITLE_2 IDC_DISPLAY3DENEDITATTRIBUTES_TITLE
#define EDIT_2 100022
#define BUTTON_1_2 100023
#define BUTTON_2_2 100024
#define ARROWLEFT 100025
#define ARROWRIGHT 100026
#define VALUE_2 IDC_DISPLAY3DENEDITATTRIBUTES_VALUE

#endif
