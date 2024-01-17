module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import Boolean;
// import IO;

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

AForm cst2ast(Form f) {
  return form("<f.name>", [ cst2ast(c) | Component c <- f.comps ], src=f.src);
}

AComponent cst2ast(Component c) {
  switch (c) {
    case (Component)`<Question q>`: return questionComponent(cst2ast(q));
    case (Component)`<Conditional cnd>`: return conditionalComponent(cst2ast(cnd));
    
    default: throw "Unhandled component: <c>";
  }
}

AQuestion cst2ast(Question q) {
  switch (q) {
    case (Question)`<Str s> <Id id> : <Type t>`: 
      return simpleQuestion(cst2ast((Expr)`<Str s>`), cst2ast((Expr)`<Id id>`), cst2ast(t), src=q.src);
    case (Question)`<Str s> <Id id> : <Type t> = <Expr e>`: 
      return computedQuestion(cst2ast((Expr)`<Str s>`), cst2ast((Expr)`<Id id>`), cst2ast(t), cst2ast(e), src=q.src);
    // case (Question)`<Str s> <Id id> : <Type t> = <BoolExpr be>`: 
    //   return computedQuestion(cst2ast((Expr)`<Str s>`), cst2ast((Expr)`<Id id>`), cst2ast(t), cst2ast(be), src=q.src);

    default: throw "Unhandled question: <q>";
  }
}

AConditional cst2ast(Conditional cnd) {
  switch (cnd) {
    case (Conditional)`if ( <BoolExpr be> ) { <Component* cs> }`:
      return ifThen(cst2ast(be), [ cst2ast(c) | Component c <- cs ], src=cnd.src);
    case (Conditional)`if ( <BoolExpr be> ) { <Component* tcs> } else { <Component* ecs> }`:
      return ifThenElse(cst2ast(be), [ cst2ast(c) | Component c <- tcs ], [ cst2ast(c) | Component c <- ecs ], src=cnd.src);

    default: throw "Unhandled conditional: <cnd>";
  }
}

ABoolExpr cst2ast(BoolExpr be) {
  switch (be) {
    case (BoolExpr)`<Id x>`                          : return bref(id("<x>", src=x.src), src=be.src);
    case (BoolExpr)`<Bool b>`                        : return boolean(fromString("<b>"), src=b.src); 
    case (BoolExpr)`(<BoolExpr bex>)`                : return parentheses(cst2ast(bex), src=be.src);
    case (BoolExpr)`<BoolExpr lhs> && <BoolExpr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<BoolExpr lhs> || <BoolExpr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`! <BoolExpr bex>`                : return not(cst2ast(bex), src=be.src);
    case (BoolExpr)`<Expr lhs> \> <Expr rhs>`        : return gt(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<Expr lhs> \< <Expr rhs>`        : return lt(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<Expr lhs> \>= <Expr rhs>`       : return geq(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<Expr lhs> \<= <Expr rhs>`       : return leq(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<Expr lhs> == <Expr rhs>`        : return eq(cst2ast(lhs), cst2ast(rhs), src=be.src);
    case (BoolExpr)`<Expr lhs> != <Expr rhs>`        : return neq(cst2ast(lhs), cst2ast(rhs), src=be.src);
  
    default: throw "Unhandled boolean expression: <be>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Int i>`                : return intgr(toInt("<i>"), src=i.src);
    case (Expr)`<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> - <Expr rhs>`: return sub(cst2ast(lhs), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=e.src);
    case (Expr)`(<Expr ex>)`            : return inBetweenParantherses(cst2ast(ex), src=e.src);
    case (Expr)`<Id x>`                 : return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Str s>`                : return strg("<s>", src=s.src);
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
    switch (t) {
        case (Type)`boolean`: return boolean(src=t.src);
        case (Type)`integer`: return integer(src=t.src);
        case (Type)`string`: return string(src=t.src);
        default: throw "Unhandled type: <t>";
    }
}
