module CST2AST

import Syntax;
import AST;

import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] f) = cst2ast(f.top);

AForm cst2ast(f:(Form)`form <Id id> <Component* cs>`) 
  = form(cst2ast(id), [ cst2ast(c) | Component c <- cs ], src=f.src);

AComponent cst2ast(c:(Component)`<Question q>`) {
  return cst2ast(q);
}

AComponent cst2ast(c:(Component)`<IfThenElse d>`) {
  return cst2ast(d);
}

AComponent cst2ast(Question q) {
  switch (q) {
    case (Question) `<Str q> <Id i> <Type t>`
      : return question(cst2ast(q), cst2ast(i), cst2ast(t), src=q.src);
    case (Question) `<Str q> <Id i> <Type t> <Expr e>`
      : return question(cst2ast(q), cst2ast(i), cst2ast(t), cst2ast(e), src=q.src);
      
    default: throw "Unhandled expression: <q>";
  }
}

AComponent cst2ast(c:(IfThenElse)`if ( <BoolExpr be> ) { <Component* cs> }`) {
  return conditional(cst2ast(be), [ cst2ast(c) | Component c <- cs ], src=c.src);
}

AComponent cst2ast(c:(IfThenElse)`if ( <BoolExpr be> ) {<Component* cs>} else {<Component* cs>}`) {
  return conditional(cst2ast(be), [ cst2ast(c) | Component c <- cs ], [ cst2ast(c) | Component c <- cs ], src=c.src);
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`               : return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Int n>`              : return cst2ast(n);
    case (Expr)`<Expr l> + <Expr r>`  : return add(cst2ast(l), cst2ast(r), src=e.src);
    case (Expr)`<Expr l> - <Expr r>`  : return sub(cst2ast(l), cst2ast(r), src=e.src);
    case (Expr)`<Expr l> * <Expr r>`  : return mul(cst2ast(l), cst2ast(r), src=e.src);
    case (Expr)`<Expr l> / <Expr r>`  : return div(cst2ast(l), cst2ast(r), src=e.src);
    case (Expr)`(<Expr e>)`           : return cst2ast(e);
    
    default: throw "Unhandled expression: <e>";
  }
}

ABoolExpr cst2ast(ABoolExpr e) {
  switch (e) {
    case (ABoolExpr)`(<BoolExpr e>)`                : return cst2ast(e);
    case (ABoolExpr)`<Bool b>`                      : return cst2ast(b);
    case (ABoolExpr)`<Id x>`                        : return ref(id("<x>", src=x.src), src=x.src);
    case (ABoolExpr)`<BoolExpr l> && <BoolExpr r>`  : return and(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<BoolExpr l> || <BoolExpr r>`  : return or(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`! <BoolExpr e>`                : return not(cst2ast(e), src=e.src);
    case (ABoolExpr)`<Expr l> \< <Expr r>`          : return lt(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<Expr l> \> <Expr r>`          : return gt(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<Expr l> \<= <Expr r>`         : return leq(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<Expr l> \>= <Expr r>`         : return geq(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<Expr l> == <Expr r>`          : return eq(cst2ast(l), cst2ast(r), src=e.src);
    case (ABoolExpr)`<Expr l> != <Expr r>`          : return neq(cst2ast(l), cst2ast(r), src=e.src);

    default: throw "Unhandled expression: <e>";
  } 
}

AType cst2ast(Type t) {
  return t("<t>", src=t.src);
}

AStr cst2ast(Str string) = str("<s>", src=s.src);
