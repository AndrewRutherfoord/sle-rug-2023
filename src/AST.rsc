module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AId name, list[AComponent] components)
  ; 

data AComponent(loc src = |tmp:///|)
  = question(AQuestion question)
  | conditional(AConditional conditional)
  ;

data AQuestion(loc src = |tmp:///|)
  = question(str label, AId id, AType t)
  | question(str label, AId id, AType t, AExpr expr)
  ; 

data AConditional(loc src = |tmp:///|)
  = conditional(ABoolExpr, list[AComponent] components)
  | conditional(ABoolExpr, list[AComponent] components, list[AComponent] elseComponents)
  ;

data ABoolExpr(loc src = |tmp:///|)
  =  ref(AId id)
  | id(AId ident)
  | boolean(bool boolean)
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
  =  ref(AId id)
  | integer(int integer)
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  | inBetweenParantherses(AExpr expr)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = t(str t)
  ;

data AStr(loc src = |tmp:///|)
  = s(str s)
  ;