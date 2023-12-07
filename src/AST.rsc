module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AExpr id, list[AComponent] components)
  ; 

data AComponent(loc src = |tmp:///|)
  = component(AQuestion question)
  | component(AConditional conditional)
  ;

data AQuestion(loc src = |tmp:///|)
  = question(AExpr text, AExpr id, AType t)
  | question(AExpr text, AExpr id, AType t, AExpr expr)
  ; 

data AConditional(loc src = |tmp:///|)
  = conditional(ABoolExpr, list[AComponent] components)
  | conditional(ABoolExpr, list[AComponent] components, list[AComponent] elseComponents)
  ;

data ABoolExpr(loc src = |tmp:///|)
  = boolean(bool boolean)
  | parentheses(ABoolExpr expr)
  | and(ABoolExpr bLeft, ABoolExpr bRight)
  | or(ABoolExpr bLeft, ABoolExpr bRight)
  | not(ABoolExpr expr)
  | gt(AExpr nLeft, AExpr nRight)
  | lt(AExpr nLeft, AExpr nRight)
  | geq(AExpr nLeft, AExpr nRight)
  | leq(AExpr nLeft, AExpr nRight)
  | eq(AExpr nLeft, AExpr nRight)
  | neq(AExpr nLeft, AExpr nRight)
  ;

data AExpr(loc src = |tmp:///|)
  = intgr(int integer)
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  | inBetweenParantherses(AExpr expr)
  | ref(AId id)
  | strg(str string)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = string()
  | integer()
  | boolean()
  ;