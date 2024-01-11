module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

keyword MyKeywords = "if" | "else" | "form";

start syntax Form 
  = "form" Id name "{" Component* comps "}"; 

syntax Component 
  = questionComponent: Question
  | conditionalComponent: Conditional;

syntax Question 
  = simpleQuestion: Str question Id id ":" Type type
  | computedQuestion: Str question Id id ":" Type type "=" Expr expr
  ;

syntax Conditional
  = ifThen: "if" "(" BoolExpr cond ")" "{" Component* subComps "}"
  | ifThenElse: "if" "(" BoolExpr cond ")" "{" Component* thenPart "}" "else" "{" Component* elsePart "}"
  ;

syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | intgr: Int i
  | "(" Expr ")"
  | strg: Str s
  > left (
    mul: Expr "*" Expr
  | div: Expr "/" Expr
  )
  > left (
    add: Expr "+" Expr
  | sub: Expr "-" Expr
  )
  ;

syntax BoolExpr
  = Id \ "true" \ "false"
  | bln: Bool b
  | "(" BoolExpr ")"
  > non-assoc (
    not: "!" BoolExpr
  )
  > non-assoc (
    lt: Expr "\<" Expr
  | gt: Expr "\>" Expr
  | leq: Expr "\<=" Expr
  | geq: Expr "\>=" Expr
  )
  > left (
    Expr "==" Expr
  | Expr "!=" Expr
  )
  > left (and: BoolExpr "&&" BoolExpr)
  > left (or: BoolExpr "||" BoolExpr)
  ;

  
syntax Type = "boolean" | "integer" | "string";

lexical Str =  "\"" ([a-zA-Z0-9?\ :])* "\"";

lexical Int = [0-9]+;

lexical Bool = "true" | "false";
