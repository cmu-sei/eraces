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

#==================Single Connection Check  Version [0.1]========================
#Prints Out Operators that are connected with only one single connection.
#For each suboperator,if the number of input parameter is one, we notify them

package require commands
Declare Command -variable "SingleConnection" -name "Single Connection Check" -statusmessage "Analyzing Single Connections" -tooltip "Analyze for modules that have single connections which could be combined into one" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {SingleConnection} -path { "&Complexity Tools"} -position last


proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

proc Init {} {
    AddCommand SingleConnection
    AddMenu ComplexityToolMenu
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


#parameter is Expression
proc ForEachParameter {parameter} {
  global total_num_operands


  #set paraid [Get $parameter
  set paraid [Call $parameter GetFullPath]

  
  output "    parameter: "
  set parameterString [Call $parameter ToString]
  output "$parameterString"
  output "\n"
  if [ IsAExprId $parameter ] {
  
    #Counting total number of operands
    #set total_num_operands [expr { $total_num_operands + 1 }]
    incr total_num_operands

    Report $parameter $total_num_operands "Num Operand"
    output "  $>Total Operand Counted: $total_num_operands\n"



   
    
    
  } elseif [ IsAExprCall $parameter ] {
    Report $parameter "Not ExprId" "ForEachParameter"
    #This is happening. Not sure if I should consider this as operand or not
    output "  $parameter--Seems like not a operand: "
    output [Class $parameter]
    output "--------------CHECK-----------------\n"
    #ForTheRightExprCall $parameter $equation

    

  } else {
    Report $parameter "Unknown WARNING" "ForEachParameter"
    output "  $parameter--WARNING: Not Handled Parameter Type: "
    output [Class $parameter]
    output "---------------------WARNING----------\n"
  }



    
  return 1

}



#Used only when right is ExprCall
proc ForTheRightExprCall {right equation subOperator} {


  global total_num_operators

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"
  
  if {$vpredefOpr != 1} {

    #Case when operator is one of predefined and not a composite operator
    
    BrowserReport $equation $subOperator
    BrowserReport $right $equation

    #We count the number of predefined operators used
    #set total_num_operators [expr { $total_num_operators + 1 }]
    incr total_num_operators
    Report $right $total_num_operators "Num Operator"

    #if it is a predefined operator
    MapRole $right parameter ForEachParameter


    #checkDistinctOperator distinctOperatorArray $vpredefOpr
  } 

  #Switch not needed for this. But needed for different kind of complexity
  switch $vpredefOpr {

    1 { #SC_ECK_NONE  when it is another composite operator
      output "      $vpredefOpr--SC_ECK_NONE\n"

      #PASS
      #Get the operator
      #set voperator [GetRole $right operator]

      #BrowserReport $voperator $equation

      #ForTheOperator $voperator
    }

    7 { #SC_ECK_PLUS
      output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $right modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForTheRightExprCall $vmodifier $equation $subOperator

    }
    8 { #SC_ECK_SUB
      output "      $vpredefOpr--SC_ECK_SUB\n"

    }
    default {
      output "     $vpredefOpr--Not handled Operator\n"
    }
  }

  #if {$vpredefOpr == $SC_ECK_PLUS} {
    #report $right
    #output "    $vpredefOpr--ECK_PLUS\n"
    #return 1
  #}
}




#parameter is Expression
proc ForEachParameterOfSubOperator {parameter} {
  global temp_num_parameter


  #set paraid [Get $parameter
  #set paraid [Call $parameter GetFullPath]

  
  output "    parameter: "
  set parameterString [Call $parameter ToString]
  output "$parameterString"
  output "\n"
  if [ IsAExprId $parameter ] {
    #Looks like for SubOperator, this is only used for input parameter and this is called individually

  
    #Counting total number of operands
    #set total_num_operands [expr { $total_num_operands + 1 }]
    #incr total_num_operands

    #Report $parameter $total_num_operands "Num Operand"
    #output "  $>Total Operand Counted: $total_num_operands\n"

    incr temp_num_parameter
    Report $parameter $temp_num_parameter
   
    
    
  } elseif [ IsAExprCall $parameter ] {
    Report $parameter "Not ExprId" "ForEachParameter"
    #This is happening. Not sure if I should consider this as operand or not
    output "  $parameter--Seems like not a operand: "
    output [Class $parameter]
    output "--------------CHECK-----------------\n"
    #ForTheRightExprCall $parameter $equation

    Report $parameter "ExprCall"

  } else {
    Report $parameter "Unknown WARNING" "ForEachParameter"
    output "  $parameter--WARNING: Not Handled Parameter Type: "
    output [Class $parameter]
    output "---------------------WARNING----------\n"
  }



    
  return 1

}


#Handling ExprCall that means suboperators
proc ForTheRightExprCall2 {right equation subOperator} {
  global temp_num_parameter
  global num_modify_instance

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

      Report $equation
      Report $right

      #initialize
      set temp_num_parameter 0
      MapRole $right parameter ForEachParameterOfSubOperator

      if {$temp_num_parameter == 1} {
         Report $voperator "Candidate For Merge"
	 incr num_modify_instance
      }

      ForTheOperator $voperator
    }
   
    #default {
    #  output "     $vpredefOpr--Not Composite Operator\n"
    #}
  }

}


proc ForEachEquation {subOperator equation} {

  
  output "-------ForEachEquation Entry: "
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

    ForTheRightExprCall $vright $equation $subOperator
  
  } elseif [ IsAExprId $vright ] {

    output "  --    ExprId Nothing to do\n"

  } elseif [ IsAConstValue $vright ] {

    output "  --    ConstValue Nothing to do\n"


  } else {
    output "  $vright--WARNING: Not handled Expression Type---------------------WARNING----------\n"
    #return 1
  }

  return 1
}

#Handles only subOperator in equation
proc ForEachEquationHandleSubOperator {subOperator equation} {
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

    ForTheRightExprCall2 $vright $equation $subOperator
  
  }

  return 1
}



#========================================STATE MACHINES===================================

#Handling conditions on State transitions
#condition is Expression
proc ForConditionExprCall {condition} {
  #global distinctOperatorArray
  global total_num_operators

  set vpredefOpr [Get $condition predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"
  
  if {$vpredefOpr != 1} {

    #Case when operator is one of predefined and not a composite operator
    

    #We count the number of predefined operators used
    #set total_num_operators [expr { $total_num_operators + 1 }]
    incr total_num_operators
    Report $condition $total_num_operators "Num Operator"

    #if it is a predefined operator
    MapRole $condition parameter ForEachParameter


    #checkDistinctOperator distinctOperatorArray $vpredefOpr
  } 

  #Switch not needed for this. But needed for different kind of complexity
  switch $vpredefOpr {

    1 { #SC_ECK_NONE  when it is another composite operator
      output "      $vpredefOpr--SC_ECK_NONE\n"

      #PASS
      #Get the operator
      #set voperator [GetRole $condition operator]

      #BrowserReport $voperator $equation

      #ForTheOperator $voperator
    }

    7 { #SC_ECK_PLUS
      output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $condition modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForConditionExprCall $vmodifier

    }

    default {
      output "     $vpredefOpr--Not handled Operator\n"
    }
  }
}



#condition is Expression
proc ForTheCondition {condition outgoing} {
  if { $condition == "" } { return 1}
  BrowserReport $condition $outgoing

  if [ IsAExprCall $condition ] {
    output "  \[Condition ExprCall\]\n"
    ForConditionExprCall $condition
  
  }
  return 1

}

#outgoing is MainTransition
proc ForEachOutgoing { state outgoing } {

  BrowserReport $outgoing $state

  set vcondition [GetRole $outgoing condition]
  ForTheCondition $vcondition $outgoing

  return 1

}


#For state machines inside states
proc ForEachStateMachineInState {parentState stateMachine} {
  #CheckForStrongTransition $stateMachine

  
  BrowserReport $stateMachine $parentState
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine]
  MapRole $stateMachine state [list "ForEachState" $stateMachine]

  return 1

}



#Handles Equation that can be inside state. Equation can end up as operators
proc ForEachStateHandleEquation { stateMachine state } {
 

  BrowserReport $state $stateMachine

  set vname [Get $state name]
  output "\n       ForEachStateHandleEquation Entry: "
  output "$vname--"
  output [Class $state]
  output "\n"


   

    #For each equation in operator that are predefined operators
    #MapRole $state equation [list "ForEachEquation" $state]

    
         
    #For each equation that represents sub operator
    MapRole $state equation [list "ForEachEquationHandleSubOperator" $state]

    #Already being called after
    #MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]
  
  return 1
}

proc ForEachState { stateMachine state } {

  #Checking for stateMachine inside State
  MapRole $state "stateMachine" [list "ForEachStateMachineInState" $state]

  #MapRole $state outgoing [list "ForEachOutgoing" $state]

  
  return 1
}






proc ForEachStateMachine {parentOperator stateMachine} {

  BrowserReport $stateMachine $parentOperator

    #Perform counting of states first
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine]

  #Then look for statemachines inside state and transitions
  MapRole $stateMachine state [list "ForEachState" $stateMachine]

  return 1

}

#========================================STATE MACHINES    END===================================

#===========================Handling IF Blocks=============START====================
proc IsAIfBlock {identObj} {
  expr ![string compare [Class $identObj] IfBlock]
}

proc IsAIfNode {identObj} {
  expr ![string compare [Class $identObj] IfNode]
}


#Could be from then or else branch or when branc
#subOperator is Action
proc ForTheAction {action} {
  if { $action == "" } { return 1}
    
    #For each equation that represents sub operator
    MapRole $action equation [list "ForEachEquationHandleSubOperator" $action]
    
    #statemachine
    MapRole $action stateMachine [list "ForEachStateMachine" $action]


  return 1

}



#Handles IF condition
proc ForTheIfExpression {expression} {
  if { $expression == "" } { return 1}
  #Report $expression

  #Can use from State transition condition
  if [ IsAExprCall $expression ] {
    output "  \[IF Condition ExprCall\]\n"
    ForConditionExprCall $expression
  
  }
  
  return 1

}

#then is IfAction
proc ForTheThen {ifNode then} {
  if { $then == "" } { return 1}
  BrowserReport $then $ifNode

  set vaction [GetRole $then action]
  BrowserReport $vaction $then
  ForTheAction $vaction 
  return 1

}

#else is IfAction
proc ForTheElse {ifNode else} {
  if { $else == "" } { return 1}
  BrowserReport $else $ifNode

  set vaction [GetRole $else action]
  BrowserReport $vaction $else
  ForTheAction $vaction 
  return 1

}


proc ForTheIfNode {parentOperator ifNode} {
  if { $ifNode == "" } { return 1}
  
  BrowserReport $ifNode $parentOperator

  set vexpression [GetRole $ifNode expression]

  BrowserReport $vexpression $ifNode
  ForTheIfExpression $vexpression


  set vthen [GetRole $ifNode then]
  if [ IsAIfNode $vthen ] {
    ForTheIfNode $ifNode $vthen 
  } else { #IfAction
    ForTheThen $ifNode $vthen 
  }


  set velse [GetRole $ifNode else]
  if [ IsAIfNode $velse ] {
    ForTheIfNode $ifNode $velse 
  } else { #IfAction
    ForTheElse $ifNode $velse 
  }

  return 1
}


#activateBlock is ActivateBlock IfBlock
proc ForEachIfActivateBlock {parentOperator activateBlock} {
  set vifNode [GetRole $activateBlock ifNode]
  ForTheIfNode $parentOperator $vifNode
}

#===========================Handling IF Blocks=============END====================



#===========================Handling WHEN Blocks=============START====================
proc IsAWhenBlock {identObj} {
  expr ![string compare [Class $identObj] WhenBlock]
}


#whenBranch is WhenBranch
proc ForEachWhenBranch {parentOperator whenBranch} {

  set vaction [GetRole $whenBranch action]

    
  BrowserReport $whenBranch $parentOperator
  BrowserReport $vaction $whenBranch

  #Defined in IF block handling
  ForTheAction $vaction
}

proc ForEachWhenActivateBlock {parentOperator activateBlock} {
  MapRole $activateBlock whenBranch [list "ForEachWhenBranch" $parentOperator]
  return 1
}
#===========================Handling WHEN Blocks=============END====================





#Same as ForEachSubOperator but for operators from expression
proc ForTheOperator {subOperator} {


  if { $subOperator == "" } { return 1}
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {

    #BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n       ForTheOperator Entry: "
    output "$vname--"
    output [Class $subOperator]
    output "\n"

    


    #For each equation in operator that are predefined operators
    #MapRole $subOperator equation [list "ForEachEquation" $subOperator]

    
    
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator]
    
    #statemachine
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]

  #}
  return 1
}


proc ForSelectedOperator {subOperator} {
  

  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {
    BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n=========================SingleConnectionCheck=========================="
    output "\n==============ForSelectedOperator Entry: "
    output "$vname================="
    #output [Class $subOperator]
    output "\n=============================================================="
    output "\n"
   

    #For each equation in operator that are predefined operators
    #MapRole $subOperator equation [list "ForEachEquation" $subOperator]

         
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator]

    #statemachine
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]

  #}
  return 1
}



#==========================Where things start===============================
proc MainStart {selection} {
CreateReport Connection "Script Item" 300 0 "Note" 200 0
CreateBrowser "Connection"

global total_num_operators
global total_num_operands
global num_distinct_operators
global num_distinct_operands
global temp_num_parameter
global num_modify_instance

set total_num_operators 0
set total_num_operands 0

set num_distinct_operators 0
set num_distinct_operands 0


set temp_num_parameter 0
set num_modify_instance 0

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
output "Check Connection tab to identify components with single input connection\n"
#output "total_num_operators: $total_num_operators \n"
#output "total_num_operands: $total_num_operands \n"
#output "num_distinct_operators: $num_distinct_operators \n"
#output "num_distinct_operands: $num_distinct_operands \n"

#set arraysize [array size localVariableArray]
#output "last arraysize: $arraysize"

package require dialogs

proc OnMessage {command} {
  global num_modify_instance

  set nRtn [MessageDialog -name "Single Connection Result" -message "Num of existing instances to check:  $num_modify_instance\n\nPlease check \"Connection\" Tabs for details." -style ok -icon information]
  if { $nRtn == 1 } {
     return    
  }
}

OnMessage dummyCmd


}

