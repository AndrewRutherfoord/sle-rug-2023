module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AComponent] components)
  ; 

data AComponent(loc src = |tmp:///|)
  = questionComponent(AQuestion question)
  | conditionalComponent(AConditional conditional)
  ;

data AQuestion(loc src = |tmp:///|)
  = simpleQuestion(AExpr text, AExpr id, AType t)
  | computedQuestion(AExpr text, AExpr id, AType t, AExpr expr)
  // | computedQuestion(AExpr text, AExpr id, AType t, ABoolExpr boolExpr)
  ; 

data AConditional(loc src = |tmp:///|)
  = ifThen(ABoolExpr, list[AComponent] components)
  | ifThenElse(ABoolExpr, list[AComponent] components, list[AComponent] elseComponents)
  ;

data ABoolExpr(loc src = |tmp:///|)
  = bref(AId id)
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
  = ref(AId id)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | inBetweenParantherses(AExpr expr)
  | intgr(int integer)
  | strg(str string)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = string()
  | integer()
  | boolean()
  ;