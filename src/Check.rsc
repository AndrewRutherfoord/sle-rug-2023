module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};
  return tenv;
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  return {}; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  return {}; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

public list[Message] checkTypes(ABoolExpr lhs, ABoolExpr rhs, TEnv tenv, UseDef useDef, Type t) {
    list[Message] msgs = [];
    msgs += check(lhs, tenv, useDef);
    msgs += check(rhs, tenv, useDef);
    if (typeOf(lhs, tenv, useDef) != t) {
        msgs += { error("Type error", lhs.src) };
    }
    if (typeOf(rhs, tenv, useDef) != t) {
        msgs += { error("Type error", rhs.src) };
    }
    return msgs;
}

set[Message] check(ABoolExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case and(lhs, rhs): {
      msgs += checkTypes(lhs, rhs, tenv, useDef, tbool());
    }
    case or(lhs, rhs): {
      msgs += checkTypes(lhs, rhs, tenv, useDef, tbool());
    }  
    case not(e): {
      msgs += check(e, tenv, useDef);
      if (typeOf(e, tenv, useDef) != tbool()) {
        msgs += { error("Type error", e.src) };
      }
    }
    case gt(lhs, rhs): {
      msgs += check(lhs, tenv, useDef);
      msgs += check(rhs, tenv, useDef);
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Type error", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Type error", rhs.src) };
      }
    }
    case lt(lhs, rhs): {
      msgs += check(lhs, tenv, useDef);
      msgs += check(rhs, tenv, useDef);
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Type error", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Type error", rhs.src) };
      }
    }

  }
  
  return msgs; 
}

Type typeOf(ABoolExpr be, TEnv tenv, UseDef useDef) {
  switch (be) {
    case and(lhs, rhs):
      return tbool();
    case or(lhs, rhs):
      return tbool();
    case not(e):
      return tbool();
    case gt(lhs, rhs):
      return tbool();
    case lt(lhs, rhs):
      return tbool();
    case geq(lhs, rhs):
      return tbool();
    case leq(lhs, rhs):
      return tbool();
    case eq(lhs, rhs):
      return tbool();
    case neq(lhs, rhs):
      return tbool();
    case boolean(bool b):
      return tbool();
    // etc.
  }
  return tunknown();
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case mul(lhs, rhs):
      return tint();
    case div(lhs, rhs):
      return tint();
    case add(lhs, rhs):
      return tint();
    case sub(lhs, rhs):
      return tint();
    case intgr(int i):
      return tint();
    case strg(str s):
      return tstr();
    // etc.
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
 
 

