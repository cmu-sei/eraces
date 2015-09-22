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
Declare Command -variable "DataFlowMetrics" -name "DataFlow Metrics" -statusmessage "Analyzing DataFlow Metric Numbers" -tooltip "Analyze DataFlows" -OnActivateCommand OnActive -OnEnableCommand OnEnableDummy
Declare Menu -variable ComplexityToolMenu -commands {DataFlowMetrics} -path { "&Complexity Tools"} -position last


proc OnActive {command} {
  MainStart $::selection
}


proc OnEnableDummy {command} {
    set length [llength $::selection] 
    return [expr { $length == 1 }] 
}

proc Init {} {
    AddCommand DataFlowMetrics
    AddMenu ComplexityToolMenu
}

Init




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


proc IsALocalVariable {identObj} {
  expr ![string compare [Class $identObj] LocalVariable]
}


proc IsAOperator {identObj} {
  expr ![string compare [Class $identObj] Operator]
}



proc SetCallingEquation {db id value} {
    upvar $db name

    set vname [Get $id "name"]

    #output "SetCallingEquation Operator: $vname\n"

    set name($id) $value

    #output "        Value: $name($id)\n"
    return 1
}

proc GetCallingEquation {db id} {
    upvar $db name

    set vname [Get $id "name"]

    #output "GetCallingEquation Operator: $vname\n"

    return $name($id)
}


#This is used to get out of feedback loops
#eq equation (equation that calls the PRE, FBY, or has last)
#value currentInputValue (path)
proc CheckPreviousEquationUsage {db eq value} {
    upvar $db name

    #set vname [Get $id "name"]

  #output [Class $value]
  #output ">>>...\n>>>"
  #output [Call $value ToString]
  #output "\n"

    if {[ info exists name($eq) ]} {
      if {$name($eq) == $value} {

         return 1
      } else {
         set name($eq) $value

	 return 0
      }
      
    } else {

      set name($eq) $value
    }

    return 0
}


proc BrowserReportWrapper {child parent} {

  BrowserReport $child $parent
  return 1
}


#Data dependency can occur through operators that have ExprCall as their parameter
#In this case we look for ExprId once more but not increase parameterIndex
#Example case is second and third parameter of IF
proc ForEachCheckParameterInParameter {equation parentEquation input parameter} {
  global parameterIndex
  global parameterFound
  global childOperator
  global lastOperatorMap
  global currentInputValue

  
  #output "    parameter: "
  #set parameterString [Call $parameter ToString]
  #output "$parameterString"
  #output "\n"
  if [ IsAExprId $parameter ] {

    set vreference [GetRole $parameter reference]

    if {$vreference == $input} {
      #output "  $vreference--    ForEachCheckParameterInParameter ExprId Input Found\n\n\n"

      #Found Input assignment to a internal variable
      BrowserReportWrapper $equation $parentEquation
      #Report $input "Identified as Parameter to Operator"      For debugging uncomment DEBUG1

      set vright [GetRole $equation right]
      set childOperator [GetRole $vright operator]
      
      
      #set parameterFound $parameterIndex


      #Checking whether it uses last
      set vlast [Get $parameter last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	if {$isCyclic != 1} {
           set parameterFound $parameterIndex
	} else {

           set iname [Get $currentInputValue name]
           Report $parameter "Terminating due to possible Cycle" $iname
	}

      } else {
        set parameterFound $parameterIndex
      }




    } 

    
    
  } elseif [ IsAExprCall $parameter ] {
    #Report $parameter "Not ExprId" "ForEachCheckParameter"
    #This is happening. Not sure if I should consider this as operand or not
    output "  $parameter--Didn't expect this: "
    output [Class $parameter]
    output "--------------ForEachCheckParameterInParameter CHECK-----------------\n"
    

  } else {
    #Report $parameter "Unknown WARNING" "ForEachCheckParameter"
    #output "  $parameter--WARNING: Not Handled Parameter Type: "
    #output [Class $parameter]
    #output "---------------------ForEachCheckParameterInParameter WARNING----------\n"
  }

    
  return 1

}



#parameter is Expression
#Checking if parameter to an operator
#equation: holds the Expression on the right where parameter is used
#subOperator: where equation exists, seems not needed
#parentEquation: would be parent if input match with parameter
#input: input that we are looking for usage
proc ForEachCheckParameter {equation parentEquation input parameter} {
  global parameterIndex
  global parameterFound
  global childOperator
  global lastOperatorMap
  global currentInputValue


  incr parameterIndex
  
  #output "    parameter: "
  set parameterString [Call $parameter ToString]
  #output "$parameterString"
  #output "\n"
  if [ IsAExprId $parameter ] {

    set vreference [GetRole $parameter reference]

    if {$vreference == $input} {
      #output "  $vreference--    ForEachCheckParameter ExprId Input Found\n\n\n"


      #Found Input assignment to a internal variable
      BrowserReportWrapper $equation $parentEquation
      #Report $input "Identified as Parameter to Operator"    For debugging uncomment DEBUG1

      set vright [GetRole $equation right]
      set childOperator [GetRole $vright operator]
      

      #set parameterFound $parameterIndex

      set vlast [Get $parameter last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	if {$isCyclic != 1} {
           set parameterFound $parameterIndex

	} else {

           set iname [Get $currentInputValue name]
           Report $parameter "Terminating due to possible Cycle" $iname
	}

      } else {
        set parameterFound $parameterIndex
      }

    } 

    
    
  } elseif [ IsAExprCall $parameter ] {
    #Report $parameter "Not ExprId" "ForEachCheckParameter"
    #This is happening. Not sure if I should consider this as operand or not
    #output "  $parameter--Seems like not a operand: "
    #output [Class $parameter]
    #output "--------------ForEachCheckParameter Continue checking-----------------\n"

    MapRole $parameter "parameter" [list "ForEachCheckParameterInParameter" $equation $parentEquation $input]
    

  } else {
    #Report $parameter "Unknown WARNING" "ForEachCheckParameter"

    #Normally you will get a lot of ConstValue that cause this warning
    #output "  $parameter--WARNING: Not Handled Parameter Type: "
    #output [Class $parameter]
    #output "---------------------ForEachCheckParameter WARNING----------\n"
  }



    
  return 1

}


proc ForEachTransitionCheckParameter {parentEquation input parameter} {
  global parameterIndex
  global parameterFound
  #global childOperator
  global lastOperatorMap
  global currentInputValue

  incr parameterIndex
  
  #output "    parameter: "
  set parameterString [Call $parameter ToString]
  #output "$parameterString"
  #output "\n"
  if [ IsAExprId $parameter ] {

    set vreference [GetRole $parameter reference]

    if {$vreference == $input} {
      #output "  $vreference--    ForEachTransitionCheckParameter ExprId Input Found\n"

      #Found Input assignment to a internal variable
      #BrowserReportWrapper $outgoing $parentEquation
      #Report $input "Identified as Parameter in Transition"     For debugging uncomment DEBUG1

      #set vright [GetRole $equation right]
      #set childOperator [GetRole $vright operator]
      
      #set parameterFound $parameterIndex


      set vlast [Get $parameter last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	if {$isCyclic != 1} {
           set parameterFound $parameterIndex

	} else {

           set iname [Get $currentInputValue name]
           Report $parameter "Terminating due to possible Cycle" $iname
	}

      } else {
        set parameterFound $parameterIndex
      }


    } 
    
    
  } elseif [ IsAExprCall $parameter ] {
    #Report $parameter "Not ExprId" "ForEachTransitionCheckParameter"
    #This is happening. Not sure if I should consider this as operand or not
    output "  $parameter--Seems like not a operand: "
    output [Class $parameter]
    output "--------------ForEachTransitionCheckParameter CHECK-----------------\n"

    

  } else {
    #Report $parameter "Unknown WARNING" "ForEachTransitionCheckParameter"
    output "  $parameter--WARNING: Not Handled Parameter Type: "
    output [Class $parameter]
    output "---------------------ForEachTransitionCheckParameter WARNING----------\n"
  }



    
  return 1

}




#Checking to see if input is used as parameter
proc ForTheRightExprCall {right equation subOperator equationOwner parentEquation input} {
set vname [Get $subOperator name]
   #output "   ForTheRightExprCall subOperator: $vname=================DEBUG\n"

  global callingEquationMap
  global parameterIndex
  global parameterFound
  global childOperator

  global preOperatorMap
  global fbyOperatorMap
  global currentInputValue

  #global distinctOperatorArray

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]

  #output "    \[$vpredefOpr\]--ForTheRightExprCall OperatorValue\n"
  
  if {$vpredefOpr != 1} {
    #Case when operator is one of PREDEFINED and not a composite operator
    
    #if it is a predefined operator
    set parameterIndex 0
    set parameterFound 0
    #unset childOperator
    MapRole $right parameter [list "ForEachCheckParameter" $equation $parentEquation $input]


    if {$parameterFound > 0} {
      #Means that we found input in parameter of predefined operator
      

      switch $vpredefOpr {
    

        26 { #SC_ECK_PRE 26
          #output "      $vpredefOpr--SC_ECK_PRE\n"

          #Tried a way to pass the first PRE operator for each global input. Has other issues
	  set isCyclic [CheckPreviousEquationUsage preOperatorMap $equation $currentInputValue]

	  #Currently we stop in all PRE
          #set isCyclic 1
	  if {$isCyclic != 1} {
             #Use the same equation as parent and continue with left
             MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
	  } else {

             set iname [Get $currentInputValue name]
             Report $equation "Terminating due to possible Cycle" $iname
	  }

        }

	30 { #SC_ECK_FBY 30
          #output "      $vpredefOpr--SC_ECK_FBY\n"

          set isCyclic [CheckPreviousEquationUsage fbyOperatorMap $equation $currentInputValue]

	  #Currently we stop in all FBY
          #set isCyclic 1
	  if {$isCyclic != 1} {
             #Use the same equation as parent and continue with left
             MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
	  } else {

             set iname [Get $currentInputValue name]
             Report $equation "Terminating due to possible Cycle" $iname
	  }

        }
    
        default {
          #Use the same equation as parent and continue with left
          MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
        }
      }

      

    }

  } else {
    #Does same but visits operator (for non generics)
    set parameterIndex 0
    set parameterFound 0
    #unset childOperator
    MapRole $right parameter [list "ForEachCheckParameter" $equation $parentEquation $input]


    if {$parameterFound > 0} {
      #Means that we found input in parameter



      set vgeneric [Get $childOperator generic]

      #For generic operators we do not go inside. Makes data path too long.
      if {$vgeneric == 0} {
        BrowserReportWrapper $childOperator $equation


        set iname [Get $currentInputValue name]
        Report $equation "Called Operator" $iname $vname
        
	#Save parent of child operator before going in for later comming out
        SetCallingEquation callingEquationMap $childOperator $equation

        ForTheOperator $childOperator $parameterFound

      } else {

        #Skipping for generic operator
	set iname [Get $currentInputValue name]
        Report $equation "Called Generic Operator" $iname $vname
        MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]

      }

      


    }
    
  }


  switch $vpredefOpr {


    7 { #SC_ECK_PLUS
      #output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $right modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForTheRightExprCall $vmodifier $equation $subOperator $equationOwner $parentEquation $input

    }

    default {
      #output "     $vpredefOpr--Not handled Operator\n"
    }
  }

}







#========================================Handling STATE MACHINES Start===================================

#Disperse equations such as A<B  without check matching parameter
proc ForTheRightExprCallDisperse {right equation subOperator equationOwner parentEquation} {
  set vname [Get $subOperator name]
  #output "   ForTheRightExprCallDisperse subOperator: $vname=================DEBUG\n"

  global callingEquationMap
  global parameterIndex
  global parameterFound
  global childOperator

  global preOperatorMap
  global fbyOperatorMap
  global currentInputValue

  #global distinctOperatorArray

  #if { $right == "" } { return 1}
  set vpredefOpr [Get $right predefOpr]



  #output "    \[$vpredefOpr\]--ForTheRightExprCallDisperse OperatorValue\n"

  #Always
  BrowserReportWrapper $equation $parentEquation
  
  if {$vpredefOpr != 1} {
    #Case when operator is one of PREDEFINED and not a composite operator
      
      switch $vpredefOpr {
    
        26 { #SC_ECK_PRE 26
          #output "      $vpredefOpr--SC_ECK_PRE\n"

          #Tried a way to pass the first PRE operator for each global input. Has other issues
	  set isCyclic [CheckPreviousEquationUsage preOperatorMap $equation $currentInputValue]

	  #Currently we stop in all PRE
          #set isCyclic 1
	  if {$isCyclic != 1} {
             #Use the same equation as parent and continue with left
             MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
	  } else {

             set iname [Get $currentInputValue name]
             Report $equation "Terminating due to possible Cycle" $iname
	  }

        }

	30 { #SC_ECK_FBY 30
          #output "      $vpredefOpr--SC_ECK_FBY\n"

          set isCyclic [CheckPreviousEquationUsage fbyOperatorMap $equation $currentInputValue]

	  #Currently we stop in all FBY
          #set isCyclic 1
	  if {$isCyclic != 1} {
             #Use the same equation as parent and continue with left
             MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
	  } else {

             set iname [Get $currentInputValue name]
             Report $equation "Terminating due to possible Cycle" $iname
	  }

        }
    
        default {
          #Use the same equation as parent and continue with left
          MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
        }
      }


  } else {
    #Does same but visits operator (for non generics)

    #unset childOperator
    set childOperator [GetRole $right operator]

    #No need to check parameter
    #MapRole $right parameter [list "ForEachCheckParameter" $equation $parentEquation $input]


    #if {$parameterFound > 0} {
      #Means that we found input in parameter

      set vgeneric [Get $childOperator generic]

      #For generic operators we do not go inside. Makes data path too long.
      if {$vgeneric == 0} {
        BrowserReportWrapper $childOperator $equation


        set iname [Get $currentInputValue name]
        Report $equation "Called Operator" $iname $vname
        
	#Save parent of child operator before going in for later comming out
        SetCallingEquation callingEquationMap $childOperator $equation

        #Goes deeper into operator
        ForTheOperatorDisperse $childOperator

      } else {

        #Skipping for generic operator
	set iname [Get $currentInputValue name]
        
	#Report $equation "Called Generic Operator" $iname $vname       For debugging uncomment DEBUG1


        MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]

      }

      


    #}
    
  }


  switch $vpredefOpr {


    7 { #SC_ECK_PLUS
      #output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $right modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForTheRightExprCallDisperse $vmodifier $equation $subOperator $equationOwner $parentEquation

    }

    default {
      #output "     $vpredefOpr--Not handled Operator\n"
    }
  }

}






#All equations are called and followed for data flow
#Similar to ForConnectingEquation
#subOperator one that has interfaces
proc ForEachEquationDisperse {subOperator parentState equation } {
  global currentInputValue
  global lastOperatorMap

  #output "-------ForEachEquationDisperse Entry: "
  #output [Class $equation]
  #output ">>>...\n>>>"
  #output [Call $equation ToString]
  #output "\n"

  #getting the right side of equation (Expression Type)
  set vright [GetRole $equation right]

  if [ IsAExprCall $vright ] {
    
    #output "  \[ExprCall\] ForEachEquationDisperse \n"

    ForTheRightExprCallDisperse $vright $equation $subOperator $parentState $parentState


  #For disperse, we only start with nonExprCall
  } elseif [ IsAExprId $vright ] {
   

    set vreference [GetRole $vright reference]

    set isInternal [Call $vreference IsInternal]
    #output "isInternal: $isInternal\n"

    #Ignore equations with internal variable on right
    if { $isInternal != "true" } {
      BrowserReportWrapper $equation $parentState
      #Report $equation "target state equation"        For debugging uncomment DEBUG1

      #MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentState $equation]

      set vlast [Get $vright last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	if {$isCyclic != 1} {
           MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentState $equation]
	} else {

           set iname [Get $currentInputValue name]
           Report $vright "Terminating due to possible Cycle" $iname
	}

      } else {
        MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentState $equation]
      }
    }


  } elseif [ IsAConstValue $vright ] {
    BrowserReportWrapper $equation $parentState
    #Report $equation "target state equation"      For debugging uncomment DEBUG1

    #output "  --    ConstValue\n"
    MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentState $equation]

  } else {
    output "  Not handled Expression Type\n"
    #return 1
  }


  return 1

}

#parent is likely transition
proc ForStateDisperseEquation {subOperator state} {

  set vname [Get $state name]
  #output "\n       ForStateDisperseEquation Entry: "
  #output "$vname--"
  #output [Class $state]
  #output "\n"

  #check for input in equations of state
  MapRole $state equation [list "ForEachEquationDisperse" $subOperator $state]

}

#Handling conditions on State transitions. Compare with ForTheRightExprCall
#condition is Expression
proc ForConditionExprCall {subOperator condition outgoing parentEquation input} {
  global parameterIndex
  global parameterFound

  set vpredefOpr [Get $condition predefOpr]

  #output "    \[$vpredefOpr\]--ForConditionExprCall OperatorValue\n"
  
  if {$vpredefOpr != 1} {

    #Case when operator is one of predefined and not a composite operator
    set parameterIndex 0
    set parameterFound 0


    #unset childOperator
    MapRole $condition parameter [list "ForEachTransitionCheckParameter" $parentEquation $input]



    # for state machine transition we cant do this. Should search for next state or target of outgoing
    if {$parameterFound > 0} {
      #Means that we found input in parameter of outgoing
      BrowserReportWrapper $outgoing $parentEquation
      #Report $outgoing "in State Transition"   For debugging uncomment DEBUG1

      set vtargetState [GetRole $outgoing target]

      BrowserReportWrapper $vtargetState $outgoing

      ForStateDisperseEquation $subOperator $vtargetState


    }


  } 




  #Switch not needed for this. But needed for different kind of complexity
  switch $vpredefOpr {

    7 { #SC_ECK_PLUS
      #output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $condition modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForConditionExprCall $subOperator $vmodifier $outgoing $parentEquation $input

    }

    default {
      #output "     $vpredefOpr--Not handled Operator\n"
    }
  }
}



#condition is Expression
proc ForTheCondition {subOperator condition outgoing parentEquation input} {
  if { $condition == "" } { return 1}
  #BrowserReport $condition $outgoing

  if [ IsAExprCall $condition ] {
    #output "  \[Condition ExprCall\]\n"
    ForConditionExprCall $subOperator $condition $outgoing $parentEquation $input
  
  } elseif [ IsAExprId $condition ] {

    set vreference [GetRole $condition reference]
    #ForTheReference $vreference
    if {$vreference == $input} {
      #output "  $vreference--    ExprId Input Found in condition\n"


      BrowserReportWrapper $outgoing $parentEquation
      #Report $outgoing "in State Transition"     For debugging uncomment DEBUG1

      set vtargetState [GetRole $outgoing target]

      BrowserReportWrapper $vtargetState $outgoing

      ForStateDisperseEquation $subOperator $vtargetState


    } else { 
      #output "  --    ExprId Nope\n"
    }
  }
  return 1

}

#outgoing is MainTransition
proc ForEachOutgoing { subOperator state parentEquation input outgoing } {

  #BrowserReportWrapper $outgoing $parentEquation

  set vcondition [GetRole $outgoing condition]
  ForTheCondition $subOperator $vcondition $outgoing $parentEquation $input

  return 1

}


#For state machines inside states
proc ForEachStateMachineInState {subOperator parentState parentEquation input stateMachine} {
  #CheckForStrongTransition $stateMachine

  
  #BrowserReport $stateMachine $parentState
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $subOperator $stateMachine $parentEquation $input]
  MapRole $stateMachine state [list "ForEachState" $subOperator $stateMachine $parentEquation $input]

  return 1

}



#Handles Equation that can be inside state.
#Checking if we can find input
#subOperator one that holds interface
proc ForEachStateHandleEquation { subOperator stateMachine parentEquation input state } {

  #BrowserReport $state $stateMachine

  #set vname [Get $state name]
  #output "\n       ForEachStateHandleEquation Entry: "
  #output "$vname--"
  #output [Class $state]
  #output "\n"

  #check for input in equations of state
  MapRole $state equation [list "ForConnectingEquation" $subOperator $state $parentEquation $input]
  
  return 1
}

proc ForEachState { subOperator stateMachine parentEquation input state } {

  #Checking for stateMachine inside State
  MapRole $state "stateMachine" [list "ForEachStateMachineInState" $subOperator $state $parentEquation $input]

  MapRole $state outgoing [list "ForEachOutgoing" $subOperator $state $parentEquation $input]

  
  return 1
}




proc ForEachStateMachine {parentOperator parentEquation input stateMachine} {

  #BrowserReport $stateMachine $parentOperator

  #Perform immediate states for input in equation
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $parentOperator $stateMachine $parentEquation $input]

  #Then look for statemachines inside state and transitions
  MapRole $stateMachine state [list "ForEachState" $parentOperator $stateMachine $parentEquation $input]

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




#All equations are called and followed for data flow
#Similar to ForConnectingEquation
#subOperator one that has interfaces
proc ForEachBlockEquationDisperse {subOperator parentAction equation } {
  global lastOperatorMap
  global currentInputValue
  

  #output "-------ForEachBlockEquationDisperse Entry: "
  #output [Class $equation]
  #output ">>>...\n>>>"
  #output [Call $equation ToString]
  #output "\n"

  #getting the right side of equation (Expression Type)
  set vright [GetRole $equation right]

  if [ IsAExprCall $vright ] {
    
    #output "  \[ExprCall\] Ignore \n"
    #Ignore for disperse

    ForTheRightExprCallDisperse $vright $equation $subOperator $parentAction $parentAction


  #For disperse, we only start with nonExprCall
  } elseif [ IsAExprId $vright ] {
   

    set vreference [GetRole $vright reference]

    set isInternal [Call $vreference IsInternal]
    #output "isInternal: $isInternal\n"

    #Ignore equations with internal variable on right
    if { $isInternal != "true" } {
      BrowserReportWrapper $equation $parentAction
      #Report $equation "equation in block"     For debugging uncomment DEBUG1


      #proc ForEachLeft {subOperator equationOwner parentEquation left}

      #MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentAction $equation]


      set vlast [Get $vright last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	if {$isCyclic != 1} {
           MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentAction $equation]
	} else {

           set iname [Get $currentInputValue name]
           Report $vright "Terminating due to possible Cycle" $iname
	}

      } else {
        MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentAction $equation]
      }

    }


  } elseif [ IsAConstValue $vright ] {
    BrowserReportWrapper $equation $parentAction
    #Report $equation "equation in block"   For debugging uncomment DEBUG1

    #output "  --    ConstValue\n"
    MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $parentAction $equation]

  } else {
    output "  Not handled Expression Type\n"
    #return 1
  }


  return 1

}

#parent is likely transition
proc ForBlockDisperseEquation {subOperator parentEquation block} {


  set vaction [GetRole $block action]
  BrowserReportWrapper $vaction $parentEquation
  
  
  MapRole $vaction equation [list "ForEachBlockEquationDisperse" $subOperator $vaction]
    
  #TODO: statemachine
  #MapRole $action stateMachine [list "ForEachStateMachine" $action]

}



#Handling conditions in Ifnode. Compare with ForTheRightExprCall
#condition is Expression
proc ForConditionExprCall2 {subOperator condition ifNode parentEquation input} {
  global parameterIndex
  global parameterFound

  set vpredefOpr [Get $condition predefOpr]

  #output "    \[$vpredefOpr\]--ForConditionExprCall OperatorValue\n"
  
  if {$vpredefOpr != 1} {

    #Case when operator is one of predefined and not a composite operator
    set parameterIndex 0
    set parameterFound 0


    #unset childOperator
    MapRole $condition parameter [list "ForEachTransitionCheckParameter" $parentEquation $input]



    # for state machine transition we cant do this. Should search for next state or target of outgoing
    if {$parameterFound > 0} {
      #Means that we found input in parameter of outgoing
      BrowserReportWrapper $condition $parentEquation
      Report $condition "in If Node Condition"

      set vthen [GetRole $ifNode then]


      if [ IsAIfNode $vthen ] {
	ForTheIfNode $subOperator $condition $input $vthen
      } else { #IfAction
        #ForTheThen $ifNode $vthen 
	ForBlockDisperseEquation $subOperator $condition $vthen
      }


      set velse [GetRole $ifNode else]
      if [ IsAIfNode $velse ] {
        ForTheIfNode $subOperator $condition $input $velse
      } else { #IfAction
        #ForTheElse $ifNode $velse 
	ForBlockDisperseEquation $subOperator $condition $velse
      }

    }


  } 




  switch $vpredefOpr {

    7 { #SC_ECK_PLUS
      #output "      $vpredefOpr--SC_ECK_PLUS\n"

      set vmodifier [GetRole $condition modifier]
      if { $vmodifier == "" } { return 1}

      #then used in High order function. This will make MAPs for instance counted as two
      ForConditionExprCall $subOperator $vmodifier $ifNode $parentEquation $input

    }

    default {
      #output "     $vpredefOpr--Not handled Operator\n"
    }
  }
}



#Handles IF condition
proc ForTheIfExpression {subOperator ifNode parentEquation input expression} {
  if { $expression == "" } { return 1}
  #Report $expression

  #Can use from State transition condition
  if [ IsAExprCall $expression ] {
    #output "  \[IF Condition ExprCall\]\n"
    ForConditionExprCall2 $subOperator $expression $ifNode $parentEquation $input
  
  }
  
  return 1

}

#then is IfAction
proc ForTheThen {subOperator parentEquation input then} {
  if { $then == "" } { return 1}
  #BrowserReportWrapper $then $ifNode

  set vaction [GetRole $then action]
  #BrowserReportWrapper $vaction $then

  #ForTheAction $vaction 
  MapRole $vaction equation [list "ForConnectingEquation" $subOperator $vaction $parentEquation $input]


  return 1

}

#else is IfAction
proc ForTheElse {subOperator parentEquation input else} {
  if { $else == "" } { return 1}
  #BrowserReportWrapper $else $ifNode

  set vaction [GetRole $else action]
  #BrowserReportWrapper $vaction $else
  #ForTheAction $vaction 

  MapRole $vaction equation [list "ForConnectingEquation" $subOperator $vaction $parentEquation $input]



  return 1

}


proc ForTheIfNode {parentOperator parentEquation input ifNode} {
  if { $ifNode == "" } { return 1}
  
  #BrowserReportWrapper $ifNode $parentOperator

  set vexpression [GetRole $ifNode expression]

  #BrowserReportWrapper $vexpression $ifNode

  ForTheIfExpression $parentOperator $ifNode $parentEquation $input $vexpression


  set vthen [GetRole $ifNode then]
  if [ IsAIfNode $vthen ] {
    ForTheIfNode $parentOperator $parentEquation $input $vthen 
  } else { #IfAction
    ForTheThen $parentOperator $parentEquation $input $vthen 
  }


  set velse [GetRole $ifNode else]
  if [ IsAIfNode $velse ] {
    ForTheIfNode $parentOperator $parentEquation $input $velse 
  } else { #IfAction
    ForTheElse $parentOperator $parentEquation $input $velse 
  }

  return 1
}


#activateBlock is ActivateBlock IfBlock
proc ForEachIfActivateBlock {parentOperator parentEquation input activateBlock} {
  set vifNode [GetRole $activateBlock ifNode]
  ForTheIfNode $parentOperator $parentEquation $input $vifNode
}

#===========================Handling IF Blocks=============END====================



#===========================Handling WHEN Blocks=============START====================
proc IsAWhenBlock {identObj} {
  expr ![string compare [Class $identObj] WhenBlock]
}


proc ForThePattern {parentOperator activateBlock parentEquation input pattern whenBranch} {
  if { $pattern == "" } { return 1}
  set vreference [GetRole $pattern reference]
  #ForTheReference $vreference
  if {$vreference == $input} {
    #output "  $vreference--    ExprId Input Found in pattern\n\n\n"
    #Found Input assignment to a internal variable
    BrowserReportWrapper $activateBlock $parentEquation
    BrowserReportWrapper $pattern $activateBlock

    #Report $pattern "in Pattern"               For debugging uncomment DEBUG1

    #Disperse only the whenBranch of the pattern 
    ForEachWhenBranchDisperse $parentOperator $pattern $whenBranch

  } else { 
    #output "  --    ExprId Nope\n"
  }

  return 1

}


#whenBranch is WhenBranch
proc ForEachWhenBranch {subOperator activateBlock parentEquation input whenBranch} {
  #Checking if pattern includes input.
  #pattern is Expression
  set vpattern [GetRole $whenBranch pattern]
  if [ IsAExprId $vpattern ] {
    ForThePattern $subOperator $activateBlock $parentEquation $input $vpattern $whenBranch
  }

  #Checking action to see if input is used somewhere
  set vaction [GetRole $whenBranch action]
  MapRole $vaction equation [list "ForConnectingEquation" $subOperator $vaction $parentEquation $input]

  return 1
}

proc ForEachWhenBranchDisperse {subOperator when whenBranch} {

  set vaction [GetRole $whenBranch action]


  #BrowserReportWrapper $whenBranch $when
  #BrowserReportWrapper $vaction $whenBranch
  BrowserReportWrapper $vaction $when


  MapRole $vaction equation [list "ForEachBlockEquationDisperse" $subOperator $vaction]

  return 1
}

proc ForTheWhen {parentOperator activateBlock parentEquation input when} {
  if { $when == "" } { return 1}
  set vreference [GetRole $when reference]
  #ForTheReference $vreference
  if {$vreference == $input} {
    #output "  $vreference--    ExprId Input Found in when\n\n\n"
    #Found Input assignment to a internal variable
    BrowserReportWrapper $activateBlock $parentEquation
    BrowserReportWrapper $when $activateBlock

    #Report $when "in When"                             For debugging uncomment DEBUG1

    #Start every when branch
    MapRole $activateBlock whenBranch [list "ForEachWhenBranchDisperse" $parentOperator $when]
  

  } else { 
    #output "  --    ExprId Nope\n"
  }

  return 1

}

proc ForEachWhenActivateBlock {parentOperator parentEquation input activateBlock} {

  set vwhen [GetRole $activateBlock when]
  if [ IsAExprId $vwhen ] {
    ForTheWhen $parentOperator $activateBlock $parentEquation $input $vwhen 
  }


  MapRole $activateBlock whenBranch [list "ForEachWhenBranch" $parentOperator $activateBlock $parentEquation $input]
  return 1
}
#===========================Handling WHEN Blocks=============END====================



#updates tempResult with index of when left == output
proc ThroughOutputIndex {left output} {
  global tempCount
  global tempResult

  incr tempCount
  if {$output == $left} {
    set tempResult $tempCount
  }

  return 1

}



proc FindIndexFromOutput {subOperator left} {
  global tempCount
  global tempResult

  set tempCount 0

  MapRole $subOperator output [list "ThroughOutputIndex" $left]

  return $tempResult
}


proc ThroughOutput {index output} {
  global tempCount
  global tempOutput

  incr tempCount
  if {$tempCount == $index} {
    set tempOutput $output
  }

  return 1

}

#Give internal variable from left of equation
proc FindOutputFromIndex {callingEquation index} {
  global tempCount
  global tempOutput

  set tempCount 0
  #unset tempInput

  MapRole $callingEquation left -filter IsALocalVariable [list "ThroughOutput" $index]
  return $tempOutput
}



proc ThroughInput {index input} {
  global tempCount
  global tempInput

  incr tempCount
  if {$tempCount == $index} {
    set tempInput $input
  }

  return 1

}

proc FindInputFromIndex {subOperator index} {
  global tempCount
  global tempInput

  set tempCount 0
  #unset tempInput

  MapRole $subOperator input [list "ThroughInput" $index]
  return $tempInput
}


proc GetParentOperator {object1} {
  set parentObj [GetRole $object1 owner]
  set parentType [Class $parentObj]

  while { $parentType != "Operator"} {

    set parentObj [GetRole $parentObj owner]
    set parentType [Class $parentObj]
  }
  return $parentObj
}

#================================FOR Equation SEARCH====================================



proc SearchForEachStateMachine {parentOperator parentEquation input stateMachine} {


  #Perform immediate states for input in equation
  MapRole $stateMachine state [list "ForEachStateHandleEquation" $parentOperator $stateMachine $parentEquation $input]

  #Then look for statemachines inside state and transitions
  MapRole $stateMachine state [list "ForEachState" $parentOperator $stateMachine $parentEquation $input]

  return 1

}

#Similar to ForInput but with parentEquation
proc SearchOperatorForConnection {subOperator parentEquation input} {


  #For each equation in operator
  MapRole $subOperator equation [list "ForConnectingEquation" $subOperator $subOperator $parentEquation $input]


  #statemachine
  MapRole $subOperator stateMachine [list "SearchForEachStateMachine" $subOperator $parentEquation $input]

  #if blocks
  #MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]
  MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator $parentEquation $input]

  #when blocks
  MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator $parentEquation $input]

  return 1

}





#left is LocalVariable
#subOperator one that hold interfaces
#equationOwner This can be Operator or State or Action
proc ForEachLeft {subOperator equationOwner parentEquation left} {
   set vname [Get $subOperator name]
   set xname [Get $left name]
   #output "--->ForEachLeft subOperator: $vname========$xname=========DEBUG\n"

  global parameterOutputIndex
  global callingEquationMap
  global topOperator
  global currentInputValue

  set iname [Get $currentInputValue name]
  #Report $left "ForEachLeft Continuing..." $iname $vname         For debugging uncomment DEBUG1

  #find where left is used. Local and internal variable will be connected by this (if equationOwner is the subOperator
  #MapRole $equationOwner equation [list "ForConnectingEquation" $subOperator $equationOwner $parentEquation $left]

  #set equationOwnerType [Class $equationOwner]



    SearchOperatorForConnection $subOperator $parentEquation $left

    #MapRole $subOperator equation [list "ForConnectingEquation" $subOperator $subOperator $parentEquation $left]


  #MapRole $equationOwner equation [list "ForConnectingEquation" $subOperator $equationOwner $parentEquation $left]


  #the left can be an output
  set isOutput [Call $left IsOutput]
  #output "IsOutput: $isOutput\n"
  if { $isOutput == "true" } {

    set vname [Get $subOperator name]
    #output "   Current subOperator: $vname=================\n"

    set parameterOutputIndex [FindIndexFromOutput $subOperator $left]
    #output "   output Index: $parameterOutputIndex\n"

   

    if {$subOperator == $topOperator} {
      #Reached a output in the top operator
      Report $left "-->>>>End OUTPUT in $vname" $iname
      BrowserReportWrapper $left $parentEquation

    } else {

      set callingEquation [GetCallingEquation callingEquationMap $subOperator]
      #Report $left "->Output.. Checking Parent..." 
      #Report $parentEquation "->Output.. Checking Parent..." $iname             For debugging uncomment DEBUG1
      #Report $callingEquation ".... from this call"                             For debugging uncomment DEBUG1
      #Report $callingEquation "mid Output from this call" $iname 


      #This could be an Operator or State
      set parentEquationHolder [GetRole $callingEquation owner]
      set pname [Get $parentEquationHolder name]
      #output "    ParentEquationHolder: $pname=================\n\n"

      #Find the output using index from the calling equation.
      set matchingInternalOutput [FindOutputFromIndex $callingEquation $parameterOutputIndex]

      #We go out of the operator
      #find where matchingInternalOutput is used in parent operator

      
      set parentType [Class $parentEquationHolder]
      if { $parentType == "Operator" } {
        MapRole $parentEquationHolder equation [list "ForConnectingEquation" $parentEquationHolder $parentEquationHolder $parentEquation $matchingInternalOutput]

      } else {

        set parentOperator [GetParentOperator $parentEquationHolder]
        MapRole $parentEquationHolder equation [list "ForConnectingEquation"  $parentOperator $parentEquationHolder $parentEquation $matchingInternalOutput]
      } 

      
    
    }
    
    
   

  }

  return 1

}


#Finding connections in equation by matching input
#subOperator one that holds interface
#equationOwner one that holds equations
proc ForConnectingEquation {subOperator equationOwner parentEquation input equation} {
  global lastOperatorMap
  global currentInputValue

  set vname [Get $subOperator name]
  #output "   ForConnectingEquation subOperator: $vname=================DEBUG\n"
  
  #output "-------ForConnectingEquation Entry: "
  #output [Class $equation]
  #output ">>>...\n>>>"
  #output [Call $equation ToString]
  #output "\n"

  #getting the right side of equation (Expression Type)
  set vright [GetRole $equation right]

  if [ IsAExprCall $vright ] {
    
    #output "  \[ExprCall\]\n"

    ForTheRightExprCall $vright $equation $subOperator $equationOwner $parentEquation $input


  
  } elseif [ IsAExprId $vright ] {
    
    
    set vreference [GetRole $vright reference]
    #ForTheReference $vreference
    if {$vreference == $input} {
      #output "  $vreference--    ExprId Input Found\n\n\n"

      #Found Input assignment to a internal variable
      BrowserReportWrapper $equation $parentEquation


      #Checking whether it uses last
      set vlast [Get $vright last]
      if {$vlast == 1} {

        set isCyclic [CheckPreviousEquationUsage lastOperatorMap $equation $currentInputValue]

	#Currently we stop in all PRE
        #set isCyclic 1
	if {$isCyclic != 1} {
           #Use the same equation as parent and continue with left
           MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
	} else {

           set iname [Get $currentInputValue name]
           Report $vright "Terminating due to possible Cycle" $iname
	}

      } else {
        MapRole $equation left -filter IsALocalVariable [list "ForEachLeft" $subOperator $equationOwner $equation]
      }

      
    } else { 
      #output "  --    ExprId Nope\n"
    }



    

  } elseif [ IsAConstValue $vright ] {

    #output "  --    ConstValue Nothing to do\n"

  } else {
    #output "  Not handled Expression Type\n"
    #return 1
  }


  return 1
}










proc ForInput {subOperator input} {


  
  BrowserReportWrapper $input $subOperator


  #For each equation in operator that are predefined operators
  MapRole $subOperator equation [list "ForConnectingEquation" $subOperator $subOperator $input $input]


  #statemachine
  MapRole $subOperator stateMachine [list "ForEachStateMachine" $subOperator $input $input]

  #if blocks
  #MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator]
  MapRole $subOperator activateBlock -filter IsAIfBlock [list "ForEachIfActivateBlock" $subOperator $input $input]

  #when blocks
  MapRole $subOperator activateBlock -filter IsAWhenBlock [list "ForEachWhenActivateBlock" $subOperator $input $input]

  return 1

}



#input is LocalVariable
proc ForEachInput {subOperator input} {
  global currentInputValue
  set currentInputValue $input


  set iname [Get $currentInputValue name]
  set vname [Get $subOperator name]
  Report $input "Starting INPUT in $iname-->>>" $iname $vname



  ForInput $subOperator $input
  return 1

}


#Disperse all equations
proc ForTheOperatorDisperse {subOperator} {

  if { $subOperator == "" } { return 1}

    #BrowserReportWrapper $subOperator

    #set vname [Get $subOperator name]
    #output "\n       ForTheOperatorDisperse Entry: "
    #output "$vname--"
    #output [Class $subOperator]
    #output "\n"

    MapRole $subOperator equation [list "ForEachEquationDisperse" $subOperator $subOperator]

  return 1
}




#parameterFound index of input that needs to be followed
proc ForTheOperator {subOperator parameterFound} {


  if { $subOperator == "" } { return 1}

    #BrowserReportWrapper $subOperator

    #set vname [Get $subOperator name]
    #output "\n       ForTheOperator Entry: "
    #output "$vname--"
    #output [Class $subOperator]
    #output "\n"

    set matchingInput [FindInputFromIndex $subOperator $parameterFound]

    #Report $matchingInput "Connecting Input"             For debugging uncomment DEBUG1

    ForInput $subOperator $matchingInput


    
  return 1
}


proc ForSelectedOperator {subOperator} {

  global topOperator

  #set vimported [Get $allOperator imported]
  #if {$vimported == 1} {
    set topOperator $subOperator
    BrowserReport $subOperator

    set vname [Get $subOperator name]
    output "\n==============ForSelectedOperator Entry: "
    output "$vname================="
    output [Class $subOperator]
    output "\n"

    #For each input that is defined
    MapRole $subOperator input [list "ForEachInput" $subOperator]


  #}
  return 1
}




proc MainStart {selection} {

CreateReport DataFlow "Script Item" 200 0 "Comment" 300 0 "Current Input" 100 0 
#"DEBUG" 70 0

CreateBrowser "DataFlow"

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

  if [ IsAOperator $elem ] {
    output "Selected Element: "
    output [Class $elem]
    output "\n"

    ForSelectedOperator $elem

  } else {

    output "Please select Operator to analyze"
  }
}





output "\n\n\n\n-----------------==============SUCCESSFULLY FINISHED===========------------------\n"
#output "total_num_operators: $total_num_operators \n"
#output "total_num_operands: $total_num_operands \n"
#output "num_distinct_operators: $num_distinct_operators \n"
#output "num_distinct_operands: $num_distinct_operands \n\n"




output "Check DataFlow tabs to check data paths and input and outputs\n"
output "Limitations: cyclic dependencies may cause some data paths to seem strange\n"
#set arraysize [array size localVariableArray]
#output "last arraysize: $arraysize"

package require dialogs

proc OnMessage {command} {

  set nRtn [MessageDialog -name "DataFlow Metric Result" -message "Finished" -style ok -icon information]
  if { $nRtn == 1 } {
     return    
  }
}

#OnMessage dummyCmd

}


#TODO: IFBlocks
