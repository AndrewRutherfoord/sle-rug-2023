module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

//Transform a data Type to a string, used for specification in error messages
str typeToStr(Type t) {
	switch(t) {
		case tint(): return "integer";
		case tbool(): return "boolean";
		case tstr(): return "string";
	}
	return "unknown";
}

//Convert AType to the needed data Types
Type ATypeToDataType(AType t) {
	switch(t) {
		case string(): return tstr();
		case integer(): return tint();
		case boolean(): return tbool();
		default: return tunknown();
	}
}

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};
  visit(f) {
  	case simpleQuestion(strg(str label), ref(AId id, src = loc u), AType varType, src = loc q):
  		tenv = tenv + <q, id.name, "<label>", ATypeToDataType(varType)>;
    case computedQuestion(strg(str label), ref(AId id, src = loc u), AType varType, AExpr e, src = loc q):
    	tenv = tenv + <q, id.name, "<label>", ATypeToDataType(varType)>;
  }
  return tenv;
}

set[Message] check(AForm f) {
  set[Message] msgs = {};

  RefGraph refs = resolve(f);
  tenv = collect(f);
  useDef = refs.useDef;

  for (AComponent c <- f.components) {
  	msgs += check(c, tenv, useDef);
  } 
  
  return msgs;
}

set[Message] check(AComponent c, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  switch (c) {
    case questionComponent(q): {
      msgs += check(q, tenv, useDef);
    }
    case conditionalComponent(cc): {
      msgs += check(cc, tenv, useDef);
    }
  }
  
  return msgs;
}

set[Message] checkQuestionAndExprType(AExpr e, Type t, TEnv tenv, UseDef useDef) {
	msgs = {};
		msgs += check(e, tenv, useDef);
		typeOfExpr = typeOf(e, tenv, useDef);
		if (typeOfExpr != t && typeOfExpr != tunknown()) {
			msgs += { error("The expression type [\"<typeToStr(typeOfExpr)>\"] should match the question type [\"<typeToStr(t)>\"]", e.src) };
		}
	return msgs;
}

set[Message] checkBoolQuestionAndExprType(ABoolExpr e, TEnv tenv, UseDef useDef) {
	msgs = {};
		msgs += check(e, tenv, useDef);
		typeOfExpr = typeOf(e, tenv, useDef);
    bprintln(typeOfExpr);
		if (typeOfExpr != tbool() && typeOfExpr != tunknown()) {
			msgs += { error("The expression type [\"<typeToStr(typeOfExpr)>\"] should match the question type [\"<typeToStr(tbool())>\"]", e.src) };
		} else if (typeOfExpr == tunknown()) {
      msgs += { warning("The expression type is unknown", e.src) };
    }
	return msgs;
}

set[Message] checkName(str name, AId id, Type t, AType var, loc def) {
	if (name == id.name) {
		if (t != ATypeToDataType(var)) {
			return {error("Another question has the same name but a different type", def)};
		} else if (t == ATypeToDataType(var)) {
      return {warning("There is another question with the same name", def)};
    }
	}
	return {};
}

set[Message] checkLabel(str label, str sq, loc def, loc qloc) {
    if (label == sq && def != qloc) {
		return { warning("There is another question with the same label", def) };
    }
    return {};
}

set[Message] check(AConditional c, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (c) {
    case ifThenElse(ABoolExpr cond, list[AComponent] thenpart, list[AComponent] elsepart): { 
  			msgs += checkBoolQuestionAndExprType(cond, tenv, useDef);
  			for (AComponent component <- c.components + c.elseComponents) {
  				msgs += check(component, tenv, useDef);
  			}
  		}
		case ifThen(ABoolExpr cond, list[AComponent] components): {
			msgs += checkBoolQuestionAndExprType(cond, tenv, useDef);
  			for (AComponent component <- c.components) {
  				msgs += check(component, tenv, useDef);
  			}
  		}
  }

  return msgs;
}

// - produce an error if there are declared questions with the same name but different types. DONE
// - duplicate labels should trigger a warning DONE
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(q) {
    case simpleQuestion(strg(sq), ref(AId id, src = loc u), AType var, src = loc qloc): {
    		for (<loc def, str name, str label, Type t> <- tenv) {
    			//For all questions except for the one we are currently verifying
    			if (def != qloc) {
    				//Check for duplicate name with different type
    				msgs += checkName(name, id, t, var, def);
    				//Check for duplicate labels
					  msgs += checkLabel(label, sq, def, qloc);	
				  }	  	    	
	    	}
		}
    case computedQuestion(strg(sq), ref(AId id, src = loc u), AType var, AExpr e, src = loc qloc): {
			for (<loc def, str name, str label, Type t> <- tenv) {
				//For all questions except for the one we are currently verifying
				if (def != qloc) {
					//Check for duplicate name with different type
					msgs += checkName(name, id, t, var, def);
					//Check for duplicate labels
					msgs += checkLabel(label, sq, def, qloc);	
				} else {
					msgs += checkQuestionAndExprType(e, t, tenv, useDef);
				}
			} 
		}
  }

  return msgs;
}

public set[Message] checkBoolTypes(ABoolExpr lhs, ABoolExpr rhs, TEnv tenv, UseDef useDef, Type t) {
    set[Message] msgs = {};
    msgs += check(lhs, tenv, useDef);
    msgs += check(rhs, tenv, useDef);
    typeLeft = typeOf(lhs, tenv, useDef);
    typeRight = typeOf(rhs, tenv, useDef);
    if (typeLeft != t && typeLeft != tunknown()) {
        msgs += { error("Incompatible type error", lhs.src) };
    }
    if (typeRight != t && typeRight != tunknown()) {
        msgs += { error("Incompatible type error", rhs.src) };
    }
    return msgs;
}

public set[Message] checkTypes(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef, Type t) {
    set[Message] msgs = {};
    msgs += check(lhs, tenv, useDef);
    msgs += check(rhs, tenv, useDef);
    typeLeft = typeOf(lhs, tenv, useDef);
    typeRight = typeOf(rhs, tenv, useDef);
    if (typeLeft != t && typeLeft != tunknown()) {
        msgs += { error("Incompatible type error", lhs.src) };
    }
    if (typeRight != t && typeRight != tunknown()) {
        msgs += { error("Incompatible type error", rhs.src) };
    }
    return msgs;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    case mul(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case div(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case add(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case sub(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
  }
  
  return msgs; 
}


set[Message] check(ABoolExpr be, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch(be) {
    case and(lhs, rhs):
      msgs += checkBoolTypes(lhs, rhs, tenv, useDef, tbool());
    case or(lhs, rhs):
      msgs += checkBoolTypes(lhs, rhs, tenv, useDef, tbool());
    case not(e): {
      msgs += check(e, tenv, useDef);
      if (typeOf(e, tenv, useDef) != tbool()) {
          msgs += { error("Incompatible type error", e.src) };
      }
    }
    case gt(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case lt(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case geq(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case leq(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case eq(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
    case neq(lhs, rhs):
      msgs += checkTypes(lhs, rhs, tenv, useDef, tint());
  }
  
  return msgs; 
}

Type typeOf(ABoolExpr be, TEnv tenv, UseDef useDef) {
  switch (be) {
    case parentheses(e):
        return typeOf(e, tenv, useDef);
    case and(_, _):
      return tbool();
    case or(_, _):
      return tbool();
    case not(_):
      return tbool();
    case gt(_, _):
      return tbool();
    case lt(_, _):
      return tbool();
    case geq(_, _):
      return tbool();
    case leq(_, _):
      return tbool();
    case eq(_, _):
      return tbool();
    case neq(_, _):
      return tbool();
    case boolean(bool _):
      return tbool();
    case bref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv)
        return t;
  }
  return tunknown();
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case inBetweenParantherses(se):
      return typeOf(se, tenv, useDef);
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv)
        return t;
    case mul(_, _):
      return tint();
    case div(_, _):
      return tint();
    case add(_, _):
      return tint();
    case sub(_, _):
      return tint();
    case intgr(int _):
      return tint();
    case strg(str _):
      return tstr();
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

