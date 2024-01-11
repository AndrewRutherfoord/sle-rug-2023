module Resolve

import AST;

/*
 * Name resolution for Q
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  result = {}; 
  visit (f) {
    case ref(AId id, src = loc u): result = result + <u, "<id.name>">;
    case bref(AId id, src = loc u): result = result + <u, "<id.name>">;
  };
  return result;
}

Def defs(AForm f) {
  result = {};

  visit(f) {
    case simpleQuestion(AExpr _, ref(AId id, src = loc _), AType _, src = loc q): result = result + <"<id.name>", q>;
    case computedQuestion(AExpr _, ref(AId id, src = loc _), AType _, AExpr _, src = loc q): result = result + <"<id.name>", q>;
  }

  return result; 
}