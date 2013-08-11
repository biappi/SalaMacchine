//
//  LCLogicControlLayout.h
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

typedef enum {
    LCLogicControl_RecReady_Ch1,
    LCLogicControl_RecReady_Ch2,
    LCLogicControl_RecReady_Ch3,
    LCLogicControl_RecReady_Ch4,
    LCLogicControl_RecReady_Ch5,
    LCLogicControl_RecReady_Ch6,
    LCLogicControl_RecReady_Ch7,
    LCLogicControl_RecReady_Ch8,
    
    LCLogicControl_Solo_Ch1,
    LCLogicControl_Solo_Ch2,
    LCLogicControl_Solo_Ch3,
    LCLogicControl_Solo_Ch4,
    LCLogicControl_Solo_Ch5,
    LCLogicControl_Solo_Ch6,
    LCLogicControl_Solo_Ch7,
    LCLogicControl_Solo_Ch8,

    LCLogicControl_Mute_Ch1,
    LCLogicControl_Mute_Ch2,
    LCLogicControl_Mute_Ch3,
    LCLogicControl_Mute_Ch4,
    LCLogicControl_Mute_Ch5,
    LCLogicControl_Mute_Ch6,
    LCLogicControl_Mute_Ch7,
    LCLogicControl_Mute_Ch8,

    LCLogicControl_Select_Ch1,
    LCLogicControl_Select_Ch2,
    LCLogicControl_Select_Ch3,
    LCLogicControl_Select_Ch4,
    LCLogicControl_Select_Ch5,
    LCLogicControl_Select_Ch6,
    LCLogicControl_Select_Ch7,
    LCLogicControl_Select_Ch8,

    LCLogicControl_VSelect_Ch1,
    LCLogicControl_VSelect_Ch2,
    LCLogicControl_VSelect_Ch3,
    LCLogicControl_VSelect_Ch4,
    LCLogicControl_VSelect_Ch5,
    LCLogicControl_VSelect_Ch6,
    LCLogicControl_VSelect_Ch7,
    LCLogicControl_VSelect_Ch8,

    LCLogicControl_Assignment_Track,
    LCLogicControl_Assignment_Send,
    LCLogicControl_Assignment_Pan,
    LCLogicControl_Assignment_Plugin,
    LCLogicControl_Assignment_Eq,
    LCLogicControl_Assignment_Instrument,
    
    LCLogicControl_FaderBanks_BankLeft,
    LCLogicControl_FaderBanks_BankRight,
    LCLogicControl_FaderBanks_ChannelLeft,
    LCLogicControl_FaderBanks_ChannelRight,
    
    LCLogicControl_Flip,
    LCLogicControl_GlobalView,
    LCLogicControl_NameValue,
    LCLogicControl_SmpteBeats,
    
    LCLogicControl_F1,
    LCLogicControl_F2,
    LCLogicControl_F3,
    LCLogicControl_F4,
    LCLogicControl_F5,
    LCLogicControl_F6,
    LCLogicControl_F7,
    LCLogicControl_F8,
    
    LCLogicControl_GlobalView_MidiTracks,
    LCLogicControl_GlobalView_Inputs,
    LCLogicControl_GlobalView_AudioTracks,
    LCLogicControl_GlobalView_AudioInstrument,
    LCLogicControl_GlobalView_Aux,
    LCLogicControl_GlobalView_Busses,
    LCLogicControl_GlobalView_Outputs,
    LCLogicControl_GlobalView_User,
    
    LCLogicControl_Shift,
    LCLogicControl_Option,
    LCLogicControl_Control,
    LCLogicControl_CmdAlt,
    
    LCLogicControl_Automation_ReadOff,
    LCLogicControl_Automation_Write,
    LCLogicControl_Automation_Trim,
    LCLogicControl_Automation_Touch,
    LCLogicControl_Automation_Latch,
    
    LCLogicControl_Group,
    
    LCLogicControl_Utilities_Save,
    LCLogicControl_Utilities_Undo,
    LCLogicControl_Utilities_Cancel,
    LCLogicControl_Utilities_Enter,
    
    LCLogicControl_Marker,
    LCLogicControl_Nudge,
    LCLogicControl_Cycle,
    LCLogicControl_Drop,
    LCLogicControl_Replace,
    LCLogicControl_Click,
    LCLogicControl_Solo,
    LCLogicControl_Rewind,
    LCLogicControl_FastFwd,
    LCLogicControl_Stop,
    LCLogicControl_Play,
    LCLogicControl_Record,
    
    LCLogicControl_CursorUp,
    LCLogicControl_CursorDown,
    LCLogicControl_CursorLeft,
    LCLogicControl_CursorRight,
    
    LCLogicControl_Zoom,
    LCLogicControl_Scrub,
    
    LCLogicControl_UserSwitchA,
    LCLogicControl_UserSwitchB,
    
    LCLogicControl_FaderTouch_Ch1,
    LCLogicControl_FaderTouch_Ch2,
    LCLogicControl_FaderTouch_Ch3,
    LCLogicControl_FaderTouch_Ch4,
    LCLogicControl_FaderTouch_Ch5,
    LCLogicControl_FaderTouch_Ch6,
    LCLogicControl_FaderTouch_Ch7,
    LCLogicControl_FaderTouch_Ch8,
    LCLogicControl_FaderTouch_Master,

    LCLogicControl_SmpteLed,
    LCLogicControl_BeatsLed,
    
    LCLogicControl_RudeSoloLight,
    LCLogicControl_RelayClick,
} LCLogicControlLayout;
