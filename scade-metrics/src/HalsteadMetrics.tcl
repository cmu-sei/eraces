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

#==================Halstead Metrics  Version [0.1]========================
#Metrics based on total number and distinct number of operators and operands.


package require commands
Declare Command -variable "HalsteadMetrics" -name "Halstead Metrics" -statusmessage "Analyzing Halstead Metric Numbers" -tooltip "Analyze used operators and operands" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {HalsteadMetrics} -path { "&Complexity Tools"} -position last


proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

proc Init {} {
    AddCommand HalsteadMetrics
    AddMenu ComplexityToolMenu
}

Init



#package require commands 
#Declare Command -variable "cmdCompare" \
# -name "&Comparisons" \
# -statusmessage "Some status message" \
# -OnActivateCommand "OnActivateComparisons"

#AddCommand "cmdCompare" 

#proc OnActivateComparisons { unused } {
#  output "[Class [lindex $::selection 0]]\n" 
#}

#Declare ContextMenu -variable "ctxMenu" \
# -OnEnableMenu "OnEnableCtxMenu" \
# -commands [list "cmdCompare"] 
 
#AddContextMenu "ctxMenu" 

#proc OnEnableCtxMenu { unused } {
# set length [llength $::selection] 
# return [expr { $length == 1 }] 
#}

#Declare Command -variable "cmdCompare" \
# -name "&Comparisons" \
# -statusmessage "Some status message" \
# -OnActivateCommand "OnActivateComparisons" \
# -OnEnableCommand "OnEnableComparisons" 
  
#proc OnEnableComparisons { unused } {
# set item [lindex $::selection 0]
# set class [Class $item]
# set classes { "Model" "Package" "Operator" }
# set status [lsearch $classes $class]
# return [expr { $status != -1 }] 
#}

#proc OnActivateComparisons { unused } { 
# CreateReport "=" "Equation" 300 0 ...
# set item [lindex $::selection 0] 
# Visit [list] $item 
#}


set SC_ECK_AND 2
set SC_ECK_OR 3
set SC_ECK_XOR 4
set SC_ECK_NOT 5
set SC_ECK_SHARP 6
set SC_ECK_PLUS 7
set SC_ECK_SUB 8
set SC_ECK_NEG 9
set SC_ECK_MUL 10
set SC_ECK_REAL2INT 11
set SC_ECK_INT2REAL 12
set SC_ECK_SLASH 14
set SC_ECK_DIV 15
set SC_ECK_MOD 16
set SC_ECK_PRJ 18
set SC_ECK_CHANGE_ITH 19
set SC_ECK_LESS 20
set SC_ECK_LEQUAL 21
set SC_ECK_GREAT 22
set SC_ECK_GEQUAL 23
set SC_ECK_EQUAL 24
set SC_ECK_NEQUAL 25
set SC_ECK_PRE 26
set SC_ECK_CURRENT 27
set SC_ECK_WHEN 28
set SC_ECK_FOLLOW 29
set SC_ECK_FBY 30
set SC_ECK_IF 31
set SC_ECK_CASE 32
set SC_ECK_SEQ_EXPR 33
set SC_ECK_BLD_STRUCT 34
set SC_ECK_MAP 35
set SC_ECK_FOLD 36
set SC_ECK_MAPFOLD 37
set SC_ECK_MAPI 38
set SC_ECK_FOLDI 39
set SC_ECK_SCALAR_TO_VECTOR 40
set SC_ECK_BLD_VECTOR 41
set SC_ECK_PRJ_DYN 42
set SC_ECK_MAKE 43
set SC_ECK_FLATTEN 44
set SC_ECK_MERGE 45
set SC_ECK_REVERSE 46
set SC_ECK_TRANSPOSE 47
set SC_ECK_FIRST 48
set SC_ECK_TIMES 49
set SC_ECK_MATCH 50
set SC_ECK_SLICE 51
set SC_ECK_CONCAT 52
set SC_ECK_ACTIVATE 53
set SC_ECK_RESTART 54
set SC_ECK_FOLDW 55
set SC_ECK_FOLDWI 56
set SC_ECK_ACTIVATE_NOINIT 57
set SC_ECK_CLOCKED_ACTIVATE 58
set SC_ECK_CLOCKED_NOT 59
set SC_ECK_POS 60
set SC_ECK_MAPW 61
set SC_ECK_MAPWI 62





#proc Disp { tab element } { 
#  set name [Get $element "name"] 
#  output "${tab}${name}\n"
#  if { [Class $element] == "Folder" } {
#    set statement [list "Disp" "$tab\t"]
#    MapRole $element "element" $statement 
#    }
#    return 1
#}

#foreach item $project {
#  MapRole $item "root" [list "Disp" ""] 
#}



#output [Get $file "persistAs"]

#output [Call $file "GetPathName"]

#foreach item $project {   #project is given global variable
#  set PathName [Get $item pathname]
#  output "PathName: $PathName\n" 
#} 


#set nRootCount [Call $selection GetRootCount]    Use of a default "selection" global variable 
#output "Root count: $nRootCount\n" 

#set FolderName [Get $selection name]     #Get name of selected file
#output "Name: $FolderName\n"


#set folder [GetRole $selection folder]   Getting name of Folder where selected file is in
#set folderName [Get $folder name]
#output "Folder name: $folderName\n" 

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
  global localVariableArray

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



    #output "==========$parameterString"
    #output "\n"
    #output "$localVariableArray($parameterString)"
    #output "==========\n"
    
    #Remove when used as input
    if {[ info exists localVariableArray($parameterString) ]} {
      unset localVariableArray($parameterString)
      output "removing array\n"
    } else {
      output "array doesnt exist\n"
    }

    
    
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


proc checkDistinctOperator {db id} {
    upvar $db name


    output "Checked Operator: $id\n"
    if {[ info exists name($id) ]} {
      incr name($id)
    } else {
      set name($id) 1
    }
    output "        Count: $name($id)\n"
    return 1
}





proc ForTheRightExprCall {right equation subOperator} {
  global distinctOperatorArray
  #Want to show only equations where the right is a ExprCall

  global SC_ECK_PLUS
  global SC_ECK_SUB

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


    checkDistinctOperator distinctOperatorArray $vpredefOpr
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
proc ForEachEquation2 {subOperator equation} {
  output "-------ForEachEquation2 Entry: "
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

proc StoreLocalVariable {db variableName} {
    upvar $db name

    # Create a new ID (stored in the name array too for easy access)
    #incr name(VID)
    #set id $name(VID)

    #set name($id,operatorID) $operatorName    ;# The index is simply a string
    output "Local variable: $variableName\n"
    set name($variableName) $variableName    ;# So we can use both fixed and     
                                             # varying parts
    return 1
}



proc ForEachInternalVariable {internal} {
  #global num_distinct_operands
  global localVariableArray

  #parent operator
  #set voperator [GetRole $internal operator]
  #set vname [Get $voperator name]
  set lname [Get $internal name]
  #output "Local variable: $lname\n"

  #set num_distinct_operands [expr { $num_distinct_operands + 1 }]
  #incr num_distinct_operands




  
  #incr localVariableArray(OID)
  #set oid $localVariableArray(OID)

  StoreLocalVariable localVariableArray $lname


  return 1

}


#========================================Handling STATE MACHINES Start===================================

#Handling conditions on State transitions
#condition is Expression
proc ForConditionExprCall {condition} {
  global distinctOperatorArray
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


    checkDistinctOperator distinctOperatorArray $vpredefOpr
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
  global localVariableArray
  global num_distinct_operands

  BrowserReport $state $stateMachine

  set vname [Get $state name]
  output "\n       ForEachStateHandleEquation Entry: "
  output "$vname--"
  output [Class $state]
  output "\n"


    #For counting distinct operands, we store all internal variables and count the initial sum then
    #we remove any variable that is actually used as input parameter.
    #We count the remaining number of variables and subtract it from the initial sum.
    #This will remove internal variables used for output variables only. 
    array unset localVariableArray
    MapRole $state internal ForEachInternalVariable
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands + $arraysize }]
    output ">>>>>adding arraysize: $arraysize"

    #For each equation in operator that are predefined operators
    MapRole $state equation [list "ForEachEquation" $state]

    #Now we check number of local variables that are not removed
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands - $arraysize }]
    output ">>>>>subtracting arraysize: $arraysize"
         
    #For each equation that represents sub operator
    MapRole $state equation [list "ForEachEquation2" $state]

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
proc ForTheAction {action} {
  if { $action == "" } { return 1}
  global localVariableArray
  global num_distinct_operands


    #For counting distinct operands, we store all internal variables and count the initial sum then
    #we remove any variable that is actually used as input parameter.
    #We count the remaining number of variables and subtract it from the initial sum.
    #This will remove internal variables used for output variables only. 

    array unset localVariableArray
    MapRole $action internal ForEachInternalVariable
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands + $arraysize }]
    output ">>>>>adding arraysize: $arraysize"

    
    #For each equation in operator that are predefined operators
    MapRole $action equation [list "ForEachEquation" $action]

    #Now we check number of local variables that are not removed
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands - $arraysize }]
    output ">>>>>subtracting arraysize: $arraysize"
    
    #For each equation that represents sub operator
    MapRole $action equation [list "ForEachEquation2" $action]
    
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
  global localVariableArray
  global num_distinct_operands

  if { $subOperator == "" } { return 1}
  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {

    #BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n       ForTheOperator Entry: "
    output "$vname--"
    output [Class $subOperator]
    output "\n"

    #For counting distinct operands, we store all internal variables and count the initial sum then
    #we remove any variable that is actually used as input parameter.
    #We count the remaining number of variables and subtract it from the initial sum.
    #This will remove internal variables used for output variables only. 

    array unset localVariableArray
    MapRole $subOperator internal ForEachInternalVariable
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands + $arraysize }]
    output ">>>>>adding arraysize: $arraysize"


    #For each equation in operator that are predefined operators
    MapRole $subOperator equation [list "ForEachEquation" $subOperator]

    #Now we check number of local variables that are not removed
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands - $arraysize }]
    output ">>>>>subtracting arraysize: $arraysize"
    
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquation2" $subOperator]
    
    #statemachine
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]

  #}
  return 1
}


proc ForEachSubOperator {subOperator} {
  global localVariableArray
  global num_distinct_operands

  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {
    BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n==============ForEachSubOperator Entry: "
    output "$vname================="
    output [Class $subOperator]
    output "\n"

    #For counting distinct operands, we store all internal variables and count the initial sum then
    #we remove any variable that is actually used as input parameter.
    #We count the remaining number of variables and subtract it from the initial sum.
    #This will remove internal variables used for output variables only. 
    array unset localVariableArray
    MapRole $subOperator internal ForEachInternalVariable
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands + $arraysize }]
    output ">>>>>adding arraysize: $arraysize"

    #For each equation in operator that are predefined operators
    MapRole $subOperator equation [list "ForEachEquation" $subOperator]

    #Now we check number of local variables that are not removed
    set arraysize [array size localVariableArray]
    set num_distinct_operands [expr { $num_distinct_operands - $arraysize }]
    output ">>>>>subtracting arraysize: $arraysize"
         
    #For each equation that represents sub operator
    MapRole $subOperator equation [list "ForEachEquation2" $subOperator]

    #statemachine
    MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator]

    #if blocks
    MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]

    #when blocks
    MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator]

  #}
  return 1
}




proc MainStart {selection} {

CreateReport Halstead "Script Item" 300 0 "Count" 100 0 "Type" 150 0
CreateBrowser "Halstead"

global total_num_operators
global total_num_operands
global num_distinct_operators
global num_distinct_operands

global distinctOperatorArray

#Variable ID
global localVariableArray

set total_num_operators 0
set total_num_operands 0

set num_distinct_operators 0
set num_distinct_operands 0

#Array that will be used to store distinct predefined operators



#gets the selected file but needs to be used from FileView
if { [llength $selection] == 1 } { 
  set elem [lindex $selection 0] 
#  if { [Class $elem] == "FileRef" } { 
#    set pathname [Get $elem "pathname"] 
#    set extension [file extension $pathname] 
#    if { $extension == ".xscade" } { 
#      output "Selected File: $pathname\n"
      #OpenSourceCodeView $pathname   if xscade file, open it
#    } 
#  } else {
#    output "Selected Element: "
#    output [Class $elem]
#    output "\n"
  
#  }

  if [ IsAOperator $elem ] {
    output "Selected Element: "
    output [Class $elem]
    output "\n"

    ForEachSubOperator $elem

  } else {

    output "Please select Operator to analyze"
  }
}

output "\nIterating for distinct operators\n"
set arraysize1 [array size distinctOperatorArray]
output "distinctOperatorArray arraysize: $arraysize1\n"

#Just checking. Size of array is it.
foreach {key value} [array get distinctOperatorArray] {
 output "operator key used: $key  number of instances: $value\n"
 incr num_distinct_operators
}




output "\n\n-----------------RESULT------------------\n"
output "total_num_operators: $total_num_operators \n"
output "total_num_operands: $total_num_operands \n"
output "num_distinct_operators: $num_distinct_operators \n"
output "num_distinct_operands: $num_distinct_operands \n\n"


global volumn
global difficulty
global effort
global time_to_program
global num_bugs

set program_vocabulary [expr { $num_distinct_operators + $num_distinct_operands }]
output "program_vocabulary: $program_vocabulary \n"

set program_lenghth [expr { $total_num_operators + $total_num_operands }]
output "program_lenghth: $program_lenghth \n"

set cal_prog_length [expr { $num_distinct_operators * log10($num_distinct_operators) / log10(2) + $num_distinct_operands * log10($num_distinct_operands) / log10(2)}]
output "cal_prog_length: $cal_prog_length \n"

set volumn [expr { $program_lenghth * log10($program_vocabulary) / log10(2) }]
output "volumn: $volumn \n"

set difficulty [expr { $num_distinct_operators / 2.0 * $total_num_operands / $num_distinct_operands }]
output "difficulty: $difficulty \n"

set effort [expr { $difficulty * $volumn }]
output "effort: $effort \n"

set time_to_program [expr { $effort / 18.0 }]
output "time_to_program: $time_to_program \n"

set num_bugs [expr { pow($effort, 0.6666) / 3000.0 }]
output "num_bugs: $num_bugs \n\n"


output "Also check Halstead tab for which predefined operators were considered\n"
output "and which operands were counted for total.\n"
#set arraysize [array size localVariableArray]
#output "last arraysize: $arraysize"

package require dialogs

proc OnMessage {command} {
  global total_num_operators
  global total_num_operands
  global num_distinct_operators
  global num_distinct_operands

  global volumn
  global difficulty
  global effort
  global time_to_program
  global num_bugs


  set nRtn [MessageDialog -name "Halstead Metric Result" -message "Total Num Operators: $total_num_operators\nTotal Num Operands: $total_num_operands\nNum Distinct Operators: $num_distinct_operators \nNum Distinct Operands: $num_distinct_operands\n\nVolumn: $volumn\nDifficulty: $difficulty\nEffort: $effort\nEst. time to program: $time_to_program\nEst. num of bugs: $num_bugs\n\nPlease check \"Script\" and \"Halstead\" Tabs for details." -style ok -icon information]
  if { $nRtn == 1 } {
     return    
  }
}

OnMessage dummyCmd

}

