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

#==================Generic Type Check  Version [0.1]========================
#Checks IF conditions and CASE conditions and State Transition conditions
#to see if integers (int** or uint**) or boolean values are being used.
#For each operator, we will show a list of all such inputs

package require commands
Declare Command -variable "GenericTypeCheck" -name "Generic Type Check" -statusmessage "Searching Generic Types" -tooltip "Search for Generic Type Inputs" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {GenericTypeCheck} -path { "&Complexity Tools"} -position last


proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

proc Init {} {
    AddCommand GenericTypeCheck
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

proc IsANamedType {identObj} {
  expr ![string compare [Class $identObj] NamedType]
}


#parameter is Expression
proc ForEach_If_Parameter {parameter} {
  global total_num_operands


  #set paraid [Get $parameter
  #set paraid [Call $parameter GetFullPath]

  
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



proc ForTheType {type} {
  if { $type == "" } { return 1}
  Report $type
  return 1

}

proc ForTheReference {reference} {
  if { $reference == "" } { return 1}
  set vtype [GetRole $reference type]
  ForTheType $vtype
}


#parameter is Expression. 
proc ForEach_Case_Parameter {parameter} {
  global total_case_count
  global hasDefault
  global firstParameterCondition

  #Only checking for the Case condition
  if { $firstParameterCondition == 0 }  { return 1}

  set firstParameterCondition 0

  
  output "    ForEach_Case_Parameter: "
  set parameterString [Call $parameter ToString]
  output "$parameterString"
  output "\n"
  if [ IsAExprId $parameter ] {
    #This catches the condition for CASE
  

    set vreference [GetRole $parameter reference]
    ForTheReference $vreference
  
    
  } 
   
  return 1

}



#Used only when right is ExprCall
proc ForTheRightExprCall {right equation subOperator} {
  global total_case_count
  global hasDefault
  global firstParameterCondition

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"
  
  #if {$vpredefOpr != 1} {
  #} 

  #Switch not needed for this. But needed for different kind of complexity
  switch $vpredefOpr {

    31 { #SC_ECK_IF
      output "      $vpredefOpr--SC_ECK_IF\n"
      BrowserReport $equation $subOperator
      BrowserReport $right $equation

      Report $right

      MapRole $right parameter ForEach_If_Parameter
    }

    32 { #SC_ECK_CASE
      output "      $vpredefOpr--SC_ECK_CASE\n"
      BrowserReport $equation $subOperator
      BrowserReport $right $equation


      Report $right

      #initialize count before MapRole
      set total_case_count 0
      set firstParameterCondition 1
      #There are two parameter roles. hasDefault will be updated
      MapRole $right parameter ForEach_Case_Parameter

      #===============It is one of these two ways depending on how to handle default=================
      #set tempCountChange [expr { $total_case_count - $hasDefault }]
      #set tempCountChange $total_case_count


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


#Handling ExprCall that means suboperators
proc ForTheRightExprCall2 {right equation subOperator} {

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


  set vpredefOpr [Get $condition predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"
  
  if {$vpredefOpr != 1} {

    #Case when operator is one of predefined and not a composite operator
    
    #if it is a predefined operator
    #MapRole $condition parameter ForEachParameter


    #checkDistinctOperator distinctOperatorArray $vpredefOpr
  } 

  #Switch not needed for this. But needed for different kind of complexity
  switch $vpredefOpr {

    1 { #SC_ECK_NONE  when it is another composite operator
      output "      $vpredefOpr--SC_ECK_NONE\n"


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

  MapRole $state outgoing [list "ForEachOutgoing" $state]

  
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




proc StoreVariable {db variableName} {
    upvar $db name

    # Create a new ID (stored in the name array too for easy access)
    #incr name(VID)
    #set id $name(VID)

    #set name($id,operatorID) $operatorName    ;# The index is simply a string
    output "Variable: $variableName\n"
    set name($variableName) $variableName    ;# So we can use both fixed and     
                                             # varying parts
    return 1
}







proc ForPredefinedTypeVariable {localVariable} {
  global localVariableArray
  global num_generic_type_instance
  #parent operator
  #set voperator [GetRole $internal operator]
  #set vname [Get $voperator name]
  set lname [Get $localVariable name]
  output "Predefined variable: $lname\n"

  #set num_distinct_operands [expr { $num_distinct_operands + 1 }]
  #incr num_distinct_operands

  
  #incr localVariableArray(OID)
  #set oid $localVariableArray(OID)

  StoreVariable localVariableArray $lname
  incr num_generic_type_instance

  return 1

}


#type is NamedType. Filter for predefined
proc ForTheType {type localVariable} {
  
  if { $type == "" } { return 1}

  set isPredefined [Call $type IsPredefined]
  output "isPredefined: $isPredefined"
  output "\n"

  #Enumeration is filtered
  if { $isPredefined == "true" } { 
    set typeString [Call $type ToString]
    output "typeString: $typeString"
    output "\n"
    
    if { $typeString == "bool" || $typeString == "int8" || $typeString == "int16" || $typeString == "int32" || $typeString == "int64" || $typeString == "uint8" || $typeString == "uint16" || $typeString == "uint32" || $typeString == "uint64" || $typeString == "int"} {
      BrowserReport $type $localVariable
      Report $localVariable
      Report $type
      ForPredefinedTypeVariable $localVariable
    }

    
  }
  return 1

}

#input is LocalVariable
proc ForEachInput {subOperator input} {
  BrowserReport $input $subOperator
  
  set vtype [GetRole $input type]

  #Report $vtype
  if [ IsANamedType $vtype ] {
    ForTheType $vtype $input
  } else {
    return 1
  }
}


#Same as ForSelectedOperator but for operators from expression
proc ForTheOperator {subOperator} {
  global localVariableArray

  if { $subOperator == "" } { return 1}
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {

    #BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n       ForTheOperator Entry: "
    output "$vname--"
    output [Class $subOperator]
    output "\n"

    #For each input we save the ones that are Generic
    array unset localVariableArray
    MapRole $subOperator input [list "ForEachInput" $subOperator]

    #For each equation in operator that are predefined operators
    #MapRole $subOperator equation [list "ForEachEquation" $subOperator]

    
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator]
    

    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]

  #}
  return 1
}

proc ForSelectedOperator {subOperator} {
  global localVariableArray
  BrowserReport $subOperator

  set vname [Get $subOperator name]
  output "\n=========================GenericTypeCheck=========================="
  output "\n==============ForSelectedOperator Entry: "
  output "$vname================="
  #output [Class $subOperator]
  output "\n=============================================================="
  output "\n"

    #For each input we save the ones that are Generic
    array unset localVariableArray
    MapRole $subOperator input [list "ForEachInput" $subOperator]

    #For each equation in operator that are predefined operators
    #MapRole $subOperator equation [list "ForEachEquation" $subOperator]

         
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator]


    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]


  return 1
}



#==========================Where things start===============================
proc MainStart {selection} {

CreateReport GenericType "Script Item" 300 0 "Count" 100 0 "Type" 150 0
CreateBrowser "GenericType"

global total_case_count
global hasDefault
global firstParameterCondition
global total_num_operands
global num_distinct_operators

global num_generic_type_instance

#Variable ID
global localVariableArray

#For CASE operators
set total_case_count 0
set hasDefault 0
set firstParameterCondition 0


set total_num_operands 0

set num_distinct_operators 0
set num_generic_type_instance 0

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
output "\Double click Variables from GenericType Tab\n"
#output "total_num_operators: $total_num_operators \n"
#output "total_num_operands: $total_num_operands \n"
#output "num_distinct_operators: $num_distinct_operators \n"


#set arraysize [array size localVariableArray]
#output "last arraysize: $arraysize"

package require dialogs

proc OnMessage {command} {
  global num_generic_type_instance

  set nRtn [MessageDialog -name "Generic Type Result" -message "Num of Generic Types to check:  $num_generic_type_instance\n\nPlease check \"GenericType\" Tabs for details." -style ok -icon information]
  if { $nRtn == 1 } {
     return    
  }
}

OnMessage dummyCmd

}
