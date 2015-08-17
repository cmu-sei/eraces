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


#==================Zage Metric  Version [0.1] ========================
#Need four types of measurement for each module.
#inflows and outflows are counted by the number of input parameters and output variables
#for each user defined operator.
#fan-in and fan-out are suppose to be superordinate and subordinate modules that are
#directly connected. 

package require commands
Declare Command -variable "ZageMetrics" -name "Zage Metrics" -statusmessage "Analyzing Zage Metrics" -tooltip "Analyze inputs, outputs, fan ins and fan outs for Zage Metrics" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {ZageMetrics} -path { "&Complexity Tools"} -position last


proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

proc Init {} {
    AddCommand ZageMetrics
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







#Increase count for id(Operator) in db
proc countOperatorCall {db id} {
    upvar $db name

    set vname [Get $id name]
    #output "\n       ForTheOperator Entry: "
    #output "$vname--"
    #output [Class $id]
    #output "\n"


    output "countOperatorCall Operator: $vname\n"
    if {[ info exists name($id) ]} {
      incr name($id)
    } else {
      set name($id) 1
    }
    output "        Count: $name($id)\n"
    return 1
}



proc setOperatorNumValue {db id value} {
    upvar $db name

    set vname [Get $id name]

    output "setOperatorNumValue Operator: $vname\n"

    set name($id) $value

    output "        Value: $name($id)\n"
    return 1
}

proc countFanout {db id} {
    upvar $db name

    set vname [Get $id name]
    #output "\n       ForTheOperator Entry: "
    #output "$vname--"
    #output [Class $id]
    #output "\n"


    output "countFanout Operator: $vname\n"
    if {[ info exists name($id) ]} {
      incr name($id)
      output "        Count: $name($id)\n"
    } else {
      #set name($id) 1   disregard cases when it does not exist
    }
    
    return 1
}


proc ForEachLeft {left} {
  global temp_num_output_parameter

  incr temp_num_output_parameter

  Report $left "" $temp_num_output_parameter
  return 1

}



#parameter is Expression
proc ForEachParameterOfSubOperator {parameter} {
  global temp_num_input_parameter


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

    incr temp_num_input_parameter
    Report $parameter $temp_num_input_parameter
   
    
    
  } elseif [ IsAExprCall $parameter ] {
    #Report $parameter "Not ExprId" "ForEachParameterOfSubOperator"
    #This is happening. Not sure if I should consider this as operand or not
    output "  $parameter--Seems like not a operand: "
    output [Class $parameter]
    output "--------------CHECK-----------------\n"
    #ForTheRightExprCall $parameter $equation

    Report $parameter "ExprCall Check" "ForEachParameterOfSubOperator"

  } else {
    Report $parameter "Unknown WARNING" "ForEachParameterOfSubOperator"
    output "  $parameter--WARNING: Not Handled Parameter Type: "
    output [Class $parameter]
    output "---------------------WARNING----------\n"
    Report $parameter "Unknown Parameter Type"
  }



    
  return 1

}


#Handling ExprCall that means suboperators
#action can be Action or Operator
proc ForTheRightExprCall2 {right equation action subOperator nesting_Level} {
  global temp_num_input_parameter
  global temp_num_output_parameter
  global operatorNumInputParameterArray
  global operatorNumOutputVariableArray
  global numDirectSuboperatorsArray

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]

  output "    \[$vpredefOpr\]--OperatorValue\n"

  switch $vpredefOpr {

    1 { #SC_ECK_NONE  when it is another composite operator
      output "      $vpredefOpr--SC_ECK_NONE\n"

      #Get the operator
      set voperator [GetRole $right operator]
      BrowserReport $equation $action
      BrowserReport $voperator $equation




      Report $equation
      
      #initialize for outflows
      set temp_num_output_parameter 0
      MapRole $equation left ForEachLeft
      setOperatorNumValue operatorNumOutputVariableArray $voperator $temp_num_output_parameter
      
      
      Report $right

      #initialize for inflows
      set temp_num_input_parameter 0
      MapRole $right parameter ForEachParameterOfSubOperator
      setOperatorNumValue operatorNumInputParameterArray $voperator $temp_num_input_parameter

      #if {$temp_num_parameter == 1} {
      #   Report $voperator "Candidate For Merge"
      #}


      #Need to increase fanout number for subOperator (parent)
      countFanout numDirectSuboperatorsArray $subOperator


      Report $voperator $temp_num_input_parameter $temp_num_output_parameter

      ForTheOperator $voperator $nesting_Level
    }
   
    default {
      output "     $vpredefOpr--Not Composite Operator\n"
    }
  }

}




#Handles only subOperator in equation
#action can be Action or Operator
proc ForEachEquationHandleSubOperator {action subOperator nesting_Level equation} {
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

    ForTheRightExprCall2 $vright $equation $action $subOperator $nesting_Level
  
  }

  return 1
}






#========================================STATE MACHINES===================================


#For state machines inside states
proc ForEachStateMachineInState {parentState action parentOperator nesting_Level stateMachine} {
  
  #BrowserReport $stateMachine $parentState
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine $action $parentOperator $nesting_Level]
  MapRole $stateMachine state [list "ForEachState" $stateMachine $action $parentOperator $nesting_Level]

  return 1

}



#Handles Equation that can be inside state. Equation can end up as operators
proc ForEachStateHandleEquation { stateMachine action parentOperator nesting_Level state } {
  global current_nesting_Level

  #BrowserReport $state $stateMachine
  #Report $state $nesting_Level

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
  #MapRole $state equation [list "ForEachEquationHandleSubOperator" $state $nesting_Level]
  MapRole $state equation [list "ForEachEquationHandleSubOperator" $action $parentOperator $nesting_Level]

  
  return 1
}


proc ForEachState { stateMachine action parentOperator nesting_Level state } {
  global current_nesting_Level

  #This is for the next level
  incr nesting_Level
  if {$nesting_Level > $current_nesting_Level} {       
    set current_nesting_Level $nesting_Level
    output "  $>current_nesting_Level: $current_nesting_Level\n"
  }

  #Checking for stateMachine inside State
  MapRole $state "stateMachine" [list "ForEachStateMachineInState" $state $action $parentOperator $nesting_Level]

  #MapRole $state outgoing [list "ForEachOutgoing" $state]

  
  return 1
}






proc ForEachStateMachine {action parentOperator nesting_Level stateMachine} {
  global current_nesting_Level
  #BrowserReport $stateMachine $parentOperator

  MapRole $stateMachine state [list "ForEachStateHandleEquation" $stateMachine $action $parentOperator $nesting_Level]

  #Then look for statemachines inside state and transitions
  MapRole $stateMachine state [list "ForEachState" $stateMachine $action $parentOperator $nesting_Level]

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
proc ForTheAction {action parentOperator nesting_Level} {
  global current_nesting_Level
  if { $action == "" } { return 1}

    #This depends on whether we count BLOCKs as a level
    #incr nesting_Level
    #if {$nesting_Level > $current_nesting_Level} {       
    #  set current_nesting_Level $nesting_Level
    #  output "  $>current_nesting_Level: $current_nesting_Level\n"
    #}



    
    #For each equation that represents sub operator
    MapRole $action equation [list "ForEachEquationHandleSubOperator" $action $parentOperator $nesting_Level]
    
    #statemachine
    MapRole $action stateMachine [list "ForEachStateMachine" $action $parentOperator $nesting_Level]


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
proc ForTheThen {ifNode then parentOperator nesting_Level} {
  if { $then == "" } { return 1}
  BrowserReport $then $ifNode

  set vaction [GetRole $then action]
  BrowserReport $vaction $then
  ForTheAction $vaction $parentOperator $nesting_Level
  return 1

}

#else is IfAction
proc ForTheElse {ifNode else parentOperator nesting_Level} {
  if { $else == "" } { return 1}
  BrowserReport $else $ifNode

  set vaction [GetRole $else action]
  BrowserReport $vaction $else
  ForTheAction $vaction $parentOperator $nesting_Level
  return 1

}


proc ForTheIfNode {reportParent ifNode parentOperator nesting_Level} {
  if { $ifNode == "" } { return 1}
  
  BrowserReport $ifNode $reportParent

  set vexpression [GetRole $ifNode expression]

  BrowserReport $vexpression $ifNode
  ForTheIfExpression $vexpression


  set vthen [GetRole $ifNode then]
  if [ IsAIfNode $vthen ] {
    ForTheIfNode $ifNode $vthen $parentOperator $nesting_Level
  } else { #IfAction
    ForTheThen $ifNode $vthen $parentOperator $nesting_Level
  }


  set velse [GetRole $ifNode else]
  if [ IsAIfNode $velse ] {
    ForTheIfNode $ifNode $velse $parentOperator $nesting_Level
  } else { #IfAction
    ForTheElse $ifNode $velse $parentOperator $nesting_Level
  }

  return 1
}


#activateBlock is ActivateBlock IfBlock
proc ForEachIfActivateBlock {parentOperator nesting_Level activateBlock} {
  set vifNode [GetRole $activateBlock ifNode]
  ForTheIfNode $parentOperator $vifNode $parentOperator $nesting_Level
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
  ForTheAction $vaction $parentOperator $nesting_Level
}

proc ForEachWhenActivateBlock {parentOperator nesting_Level activateBlock} {
  MapRole $activateBlock whenBranch [list "ForEachWhenBranch" $parentOperator $nesting_Level]
  return 1
}
#===========================Handling WHEN Blocks=============END====================



#Same as ForEachSubOperator but for operators from expression
proc ForTheOperator {subOperator nesting_Level} {
  global current_nesting_Level
  global operatorCallCountArray
  global numDirectSuboperatorsArray

  if { $subOperator == "" } { return 1}
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {

    #BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n       ForTheOperator Entry: "
    output "$vname--"
    output [Class $subOperator]
    output "\n"


    #countOperatorCall operatorCallCountArray $vname
    countOperatorCall operatorCallCountArray $subOperator

    
    #For each equation that represents sub operator
    incr nesting_Level
    if {$nesting_Level > $current_nesting_Level} {       
      set current_nesting_Level $nesting_Level
      output "  $>current_nesting_Level: $current_nesting_Level\n"
    }


    #initialize for fanout
    #Need to add this as a number of fanout for subOperator
    setOperatorNumValue numDirectSuboperatorsArray $subOperator 0


    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator $subOperator $nesting_Level]
    
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator $subOperator $nesting_Level]

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
    output "\n=========================Zage Metric=========================="
    output "\n==============ForSelectedOperator Entry: "
    output "$vname================="
    #output [Class $subOperator]
    output "\n=============================================================="
    output "\n"

         
    #For each equation that represents sub operator
    incr current_nesting_Level
    MapRole $subOperator equation [list "ForEachEquationHandleSubOperator" $subOperator $subOperator 1]


    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator $subOperator 1]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator 1]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator 1]

  #}
  return 1
}



#==========================Where things start===============================
proc MainStart {selection} {

CreateReport Zage "Script Item" 200 0 "Num Input" 100 0 "Num Output" 100 0 "Num FanIn" 100 0 "Num FanOut" 100 0 "D_e value" 100 0
CreateBrowser "Zage"


#call count for Operator call
global operatorCallCountArray

global operatorNumInputParameterArray
global operatorNumOutputVariableArray
global numDirectSuboperatorsArray

global current_nesting_Level
global temp_num_input_parameter
global temp_num_output_parameter
global temp_num_fanout


set current_nesting_Level 0

set temp_num_input_parameter 0
set temp_num_output_parameter 0
set temp_num_fanout 0



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

global sumNumInput
global sumNumOutput
global sumCallCount
global sumDirSuboperator

global sumDE

global num_size

set sumNumInput 0
set sumNumOutput 0
set sumCallCount 0
set sumDirSuboperator 0
set sumDE 0

#key is Operator
foreach {key value} [array get operatorNumInputParameterArray] {
 set vname [Get $key name]
 incr sumNumInput $value
 output "Module name: $vname          Num InputFlow: $value\n"
}
output "\n\n"

foreach {key value} [array get operatorNumOutputVariableArray] {
 set vname [Get $key name]
 incr sumNumOutput $value
 output "Module name: $vname          Num OutFlow: $value\n"
}
output "\n\n"

foreach {key value} [array get operatorCallCountArray] {
 set vname [Get $key name]
 incr sumCallCount $value
 output "Module name: $vname          Num Fanin: $value\n"
}
output "\n\n"

foreach {key value} [array get numDirectSuboperatorsArray] {
 set vname [Get $key name]
 incr sumDirSuboperator $value
 output "Module name: $vname          Num Fanout: $value\n"
}
output "\n\n"

set num_size [array size numDirectSuboperatorsArray]
set num_size [expr double($num_size)]
output "Number of Operators: $num_size\n"



foreach {key value} [array get operatorNumInputParameterArray] {

 set vname [Get $key name]
 set d_e_value [expr { $value * $operatorNumOutputVariableArray($key) + $operatorCallCountArray($key) * $numDirectSuboperatorsArray($key) } ]
 incr sumDE $d_e_value

 Report $key $value $operatorNumOutputVariableArray($key) $operatorCallCountArray($key) $numDirectSuboperatorsArray($key) $d_e_value

}
output "\n\n"


package require dialogs

proc OnMessage {command} {
  global sumNumInput
  global sumNumOutput
  global sumCallCount
  global sumDirSuboperator
  global sumDE
  global num_size

  set avgSumNumInput [expr {$sumNumInput / $num_size}]
  set avgSumNumOutput [expr {$sumNumOutput / $num_size}]
  set avgSumCallCount [expr {$sumCallCount / $num_size}]
  set avgSumDirSuboperatort [expr {$sumDirSuboperator / $num_size}]
  set avgsumDE [expr {$sumDE / $num_size}]

  output "Avg Num Input: $avgSumNumInput\n"
  output "Avg Num Output: $avgSumNumOutput\n"
  output "Avg Num FanIn: $avgSumCallCount\n"
  output "Avg Num FanOut: $avgSumDirSuboperatort\n"
  output "Avg Num D_e: $avgsumDE\n"

  set nRtn [MessageDialog -name "Zage Metric Result" -message "Avg Num Input: $avgSumNumInput\nAvg Num Output: $avgSumNumOutput\nAvg Num FanIn: $avgSumCallCount\nAvg Num FanOut: $avgSumDirSuboperatort\nAvg D_e: $avgsumDE \n\nPlease check Bottom of \"Zage\" Tab for numeric details.\n(Note: used 1 as weight factors)" -style ok -icon information]
  if { $nRtn == 1 } {
      return    
  }
}

OnMessage dummyCmd

#set temp [expr { $current_nesting_Level-1 }]
#output "MAX Nesting Level: $temp \n"


}


