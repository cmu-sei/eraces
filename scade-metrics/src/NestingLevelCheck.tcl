#Copyright 2015 Carnegie Mellon University
#All Rights Reserved.

#Redistribution and use in source and binary forms, with or without modification, 
#are permitted provided that the following conditions are met:
#1. Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the following acknowledgments and disclaimers.
#2. Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following acknowledgments and disclaimers 
#   in the documentation and/or other materials provided with the distribution.
#3. Products derived from this software may not include "Carnegie Mellon University," 
#   "SEI" and/or "Software Engineering Institute" in the name of such derived product, 
#   nor shall "Carnegie Mellon University," "SEI" and/or "Software Engineering Institute" 
#   be used to endorse or promote products derived from this software without prior 
#   written permission. For written permission, please contact permission@sei.cmu.edu.
#ACKNOWLEDGMENTS AND DISCLAIMERS: Copyright 2015 Carnegie Mellon University

#This material is based upon work funded and supported by the Department of Defense under 
#Contract No. FA8721-05-C-0003 with Carnegie Mellon University for the operation of 
#the Software Engineering Institute, a federally funded research and development center.

#Any opinions, findings and conclusions or recommendations expressed in this material are 
#those of the author(s) and do not necessarily reflect the views of the United States Department of Defense.

#NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL 
#IS FURNISHED ON AN “AS-IS” BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, 
#EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS 
#FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. 
#CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, 
#TRADEMARK, OR COPYRIGHT INFRINGEMENT.

#This material has been approved for public release and unlimited distribution.

#Carnegie Mellon® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.

#DM-0002575

#==================Nesting Level Check  Version [0.1]========================
#Prints out nesting levels of Operators and States.
#Parent Operators and Parent States will contribute to levels


package require commands
Declare Command -variable "NestingLevel" -name "Nesting Level" -statusmessage "Analyzing Nesting Level" -tooltip "Analyze Nesting Level of Operator and States" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {NestingLevel} -path { "&Complexity Tools"} -position last
#Declare ContextMenu -variable ComplexityToolContextMenu -commands {NestingLevel} -OnEnableMenu "OnEnableCtxMenu"

proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

#proc OnEnableCtxMenu { unused } {
# set length [llength $::selection] 
# return [expr { $length == 1 }] 
#}

proc Init {} {
    AddCommand NestingLevel
    AddMenu ComplexityToolMenu
    #AddContextMenu ComplexityToolContextMenu
}

Init









#For filtering Expression
proc IsAExprCall {identObj} {
  expr ![string compare [Class $identObj] ExprCall]
}

proc IsAExprId {identObj} {
  expr ![string compare [Class $identObj] ExprId]
}

proc IsAConstValue {identObj} {
  expr ![string compare [Class $identObj] ConstValue]
}




proc IsAOperator {identObj} {
  expr ![string compare [Class $identObj] Operator]
}








#Handling ExprCall that means suboperators
proc ForTheRightExprCall2 {right equation subOperator nesting_Level} {

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"

  switch $vpredefOpr {

    1 { #SC_ECK_NONE  when it is another composite operator
      output "      $vpredefOpr--SC_ECK_NONE\n"

      #Get the operator
      set voperator [GetRole $right operator]
      BrowserReport $equation $subOperator
      BrowserReport $voperator $equation

      Report $voperator $nesting_Level

      ForTheOperator $voperator $nesting_Level
    }
   
    default {
      output "     $vpredefOpr--Not Composite Operator\n"
    }
  }

}




#Handles only subOperator in equation
proc ForEachEquationHandleSubOperator {subOperator nesting_Level equation} {
  output "-------ForEachEquationHandleSubOperator Entry: "
  #set tempname [Get $equation name]
  #output "  $tempname--"
  output [Class $equation]
  output ">>>...\n>>>"
  output [Call $equation ToString]
  output "\n"

  #getting the right side of equation
  set vright [GetRole $equation right]


  if [ IsAExprCall $vright ] {
    
    output "  \[ExprCall\]\n"

    ForTheRightExprCall2 $vright $equation $subOperator $nesting_Level
  
  }

  return 1
}






#========================================STATE MACHINES===================================


#For state machines inside states
proc ForEachStateMachineInState {parentState nesting_Level stateMachine} {
  
  BrowserReport $stateMachine $parentState
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine $nesting_Level]
  MapRole $stateMachine state [list "ForEachState" $stateMachine $nesting_Level]

  return 1

}



#Handles Equation that can be inside state. Equation can end up as operators
proc ForEachStateHandleEquation { stateMachine nesting_Level state } {
  global current_nesting_Level

  BrowserReport $state $stateMachine
  Report $state $nesting_Level

  set vname [Get $state name]
  output "\n       ForEachStateHandleEquation Entry: "
  output "$vname--"
  output [Class $state]
  output "\n"


  #This is for the next level
  incr nesting_Level
  if {$nesting_Level > $current_nesting_Level} {       
    set current_nesting_Level $nesting_Level
    output "  $>current_nesting_Level: $current_nesting_Level\n"
  }
         
  #For each equation that represents sub operator
  MapRole $state equation [list "ForEachEquationHandleSubOperator" $state $nesting_Level]

  
  return 1
}


proc ForEachState { stateMachine nesting_Level state } {
  global current_nesting_Level

  #This is for the next level
  incr nesting_Level
  if {$nesting_Level > $current_nesting_Level} {       
    set current_nesting_Level $nesting_Level
    output "  $>current_nesting_Level: $current_nesting_Level\n"
  }

  #Checking for stateMachine inside State
  MapRole $state "stateMachine" [list "ForEachStateMachineInState" $state $nesting_Level]

  #MapRole $state outgoing [list "ForEachOutgoing" $state]

  
  return 1
}






proc ForEachStateMachine {parentOperator nesting_Level stateMachine} {
  global current_nesting_Level
  BrowserReport $stateMachine $parentOperator

  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine $nesting_Level]

  #Then look for statemachines inside state and transitions
  MapRole $stateMachine state [list "ForEachState" $stateMachine $nesting_Level]

  return 1

}


#===========================Handling STATE MACHINES=============END====================



#===========================Handling IF Blocks=============START====================
proc IsAIfBlock {identObj} {
  expr ![string compare [Class $identObj] IfBlock]
}

proc IsAIfNode {identObj} {
  expr ![string compare [Class $identObj] IfNode]
}


#Could be from then or else branch or when branc
#subOperator is Action
proc ForTheAction {action nesting_Level} {
  global current_nesting_Level
  if { $action == "" } { return 1}

    #This depends on whether we count BLOCKs as a level
    #incr nesting_Level
    #if {$nesting_Level > $current_nesting_Level} {       
    #  set current_nesting_Level $nesting_Level
    #  output "  $>current_nesting_Level: $current_nesting_Level\n"
    #}



    
    #For each equation that represents sub operator
    MapRole $action equation [list "ForEachEquationHandleSubOperator" $action $nesting_Level]
    
    #statemachine
    MapRole $action stateMachine [list "ForEachStateMachine" $action $nesting_Level]


  return 1

}



#Handles IF condition
proc ForTheIfExpression {expression} {
  if { $expression == "" } { return 1}
  #Report $expression

  #Can use from State transition condition
  #if [ IsAExprCall $expression ] {
  #  output "  \[IF Condition ExprCall\]\n"
  #  ForConditionExprCall $expression
  # 
  #}
  
  return 1

}

#then is IfAction
proc ForTheThen {ifNode then nesting_Level} {
  if { $then == "" } { return 1}
  BrowserReport $then $ifNode

  set vaction [GetRole $then action]
  BrowserReport $vaction $then
  ForTheAction $vaction $nesting_Level
  return 1

}

#else is IfAction
proc ForTheElse {ifNode else nesting_Level} {
  if { $else == "" } { return 1}
  BrowserReport $else $ifNode

  set vaction [GetRole $else action]
  BrowserReport $vaction $else
  ForTheAction $vaction $nesting_Level
  return 1

}


proc ForTheIfNode {parentOperator ifNode nesting_Level} {
  if { $ifNode == "" } { return 1}
  
  BrowserReport $ifNode $parentOperator

  set vexpression [GetRole $ifNode expression]

  BrowserReport $vexpression $ifNode
  ForTheIfExpression $vexpression


  set vthen [GetRole $ifNode then]
  if [ IsAIfNode $vthen ] {
    ForTheIfNode $ifNode $vthen $nesting_Level
  } else { #IfAction
    ForTheThen $ifNode $vthen $nesting_Level
  }


  set velse [GetRole $ifNode else]
  if [ IsAIfNode $velse ] {
    ForTheIfNode $ifNode $velse $nesting_Level
  } else { #IfAction
    ForTheElse $ifNode $velse $nesting_Level
  }

  return 1
}


#activateBlock is ActivateBlock IfBlock
proc ForEachIfActivateBlock {parentOperator nesting_Level activateBlock} {
  set vifNode [GetRole $activateBlock ifNode]
  ForTheIfNode $parentOperator $vifNode $nesting_Level
}

#===========================Handling IF Blocks=============END====================



#===========================Handling WHEN Blocks=============START====================
proc IsAWhenBlock {identObj} {
  expr ![string compare [Class $identObj] WhenBlock]
}


#whenBranch is WhenBranch
proc ForEachWhenBranch {parentOperator nesting_Level whenBranch} {

  set vaction [GetRole $whenBranch action]

    
  BrowserReport $whenBranch $parentOperator
  BrowserReport $vaction $whenBranch

  #Defined in IF block handling
  ForTheAction $vaction $nesting_Level
}

proc ForEachWhenActivateBlock {parentOperator nesting_Level activateBlock} {
  MapRole $activateBlock whenBranch [list "ForEachWhenBranch" $parentOperator $nesting_Level]
  return 1
}
#===========================Handling WHEN Blocks=============END====================



#Same as ForEachSubOperator but for operators from expression
proc ForTheOperator {subOperator nesting_Level} {
  global current_nesting_Level

  if { $subOperator == "" } { return 1}
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {

    #BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n       ForTheOperator Entry: "
    output "$vname--"
    output [Class $subOperator]
    output "\n"


    
    #For each equation that represents sub operator
    incr nesting_Level
    if {$nesting_Level > $current_nesting_Level} {       
      set current_nesting_Level $nesting_Level
      output "  $>current_nesting_Level: $current_nesting_Level\n"
    }

    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator $nesting_Level]
    
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator $nesting_Level]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator $nesting_Level]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator $nesting_Level]

  #}
  return 1
}


proc ForSelectedOperator {subOperator} {
  global current_nesting_Level
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {
    BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n=========================NestingLevelCheck=========================="
    output "\n==============ForSelectedOperator Entry: "
    output "$vname================="
    #output [Class $subOperator]
    output "\n=============================================================="
    output "\n"

         
    #For each equation that represents sub operator
    incr current_nesting_Level
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator 1]


    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator 1]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator 1]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator 1]

  #}
  return 1
}





#==========================Where things start===============================
proc MainStart {selection} {


CreateReport NestLevel "Script Item" 300 0 "Level" 100 0
CreateBrowser "NestLevel"

global current_nesting_Level
set current_nesting_Level 0


#Only works when single Operator is selected.
if { [llength $selection] == 1 } { 
  set elem [lindex $selection 0] 

  if [ IsAOperator $elem ] {
    output "Selected Element: "
    output [Class $elem]
    output "\n"

    ForSelectedOperator $elem

  } else {

    output "Please select Operator to analyze"
  }
}


output "\n\n-----------------RESULT------------------\n"
set temp [expr { $current_nesting_Level-1 }]
output "MAX Nesting Level: $temp \n"


package require dialogs

proc OnMessage {command} {
  global current_nesting_Level
  set temp [expr { $current_nesting_Level-1 }]
  set nRtn [MessageDialog -name "Nesting Level Result" -message "MAX Nesting Level:  $temp\n\nPlease check \"NestLevel\" Tabs for details." -style ok -icon information]
  if { $nRtn == 1 } {
      return    
  }
}

OnMessage dummyCmd

}




