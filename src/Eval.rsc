module Eval

import AST;
import Resolve;
import IO;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)

int defaultInt() = 0;
bool defaultBool() = false;
str defaultStr() = "";

Value defaultValue(AType t) {
  switch (t) {
    case integer(): return vint(defaultInt());
    case boolean(): return vbool(defaultBool());
    case string(): return vstr(defaultStr());
    default: throw "Unsupported type <t>";
  }
}

VEnv initialEnv(AForm f) {
  VEnv venv = ();
  visit(f) {
  	case simpleQuestion(strg(str label), ref(AId id, src = loc u), AType varType, src = loc q):
  		venv = venv + (id.name: defaultValue(varType));
    case computedQuestion(strg(str label), ref(AId id, src = loc u), AType varType, AExpr e, src = loc q):
      // TODO: Needs to be evaluated??
    	venv = venv + (id.name: defaultValue(varType));
  }
  return venv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  visit (f) {
    case AQuestion q : venv = eval(q, inp, venv);
    // case AConditional c : venv = eval(c, inp, venv);
  }
  return venv;
}

VEnv eval(AConditional c, Input inp, VEnv venv) {
  // TODO
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  switch (q) {
    case simpleQuestion(strg(str label), ref(AId id, src = loc u), AType varType, src = loc q):{
      if (inp.question == id.name)
        venv = venv + (id.name: inp.\value);
    }
    case  computedQuestion(strg(sq), ref(AId id, src = loc u), AType var, AExpr e, src = loc qloc): {
        venv = venv + (id.name: eval(e, venv));
    }

    default: throw "Unsupported question <q>";
  }
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case intgr(int n): return vint(n);
    case add(AExpr e1, AExpr e2): 
      return vint(eval(e1, venv).n + eval(e2, venv).n);
    case sub(AExpr e1, AExpr e2):
      return vint(eval(e1, venv).n - eval(e2, venv).n);
    case mul(AExpr e1, AExpr e2):
      return vint(eval(e1, venv).n * eval(e2, venv).n);
    case div(AExpr e1, AExpr e2):
      return vint(eval(e1, venv).n / eval(e2, venv).n);
    case inBetweenParantherses(AExpr e): 
      return eval(e, venv);    
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}


Value eval(ABoolExpr be, VEnv venv) {
  switch (be) {
    case bref(id(str x)): return venv[x];
    case boolean(bool bv): return vbool(bv);
    case and(ABoolExpr bLeft, ABoolExpr bRight):
      return vbool(eval(bLeft, venv).b && eval(bRight, venv).b);
    case or(ABoolExpr bLeft, ABoolExpr bRight):
      return vbool(eval(bLeft, venv).b || eval(bRight, venv).b);
    case gt(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n > eval(nRight, venv).n);
    case lt(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n < eval(nRight, venv).n);
    case geq(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n <= eval(nRight, venv).n);
    case leq(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n <= eval(nRight, venv).n);
    case eq(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n == eval(nRight, venv).n);
    case neq(AExpr nLeft, AExpr nRight):
      return vbool(eval(nLeft, venv).n != eval(nRight, venv).n);
    case not(ABoolExpr e):
      return eval(e, venv).b;
    // TODO: other cases
    default: throw "Unsupported expression <be>";
    
  }
}