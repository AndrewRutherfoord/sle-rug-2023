module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

keyword MyKeywords = "if" | "else" | "form";

start syntax Form 
  = "form" Id name "{" Component* comps "}"; 

syntax Component = Question | Conditional;

syntax Question 
  = Str Id id ":" Type type
  | Str Id id ":" Type type "=" Expr expr
  ;

syntax Conditional
  = "if" "(" BoolExpr ")" "{" Component* subComps "}"
  | "if" "(" BoolExpr ")" "{" Component* subComps "}" "else" "{" Component* subComps "}"
  ;

syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  > left (
    mul: Expr "*" Expr
  | div: Expr "/" Expr
  )
  > left (
    add: Expr "+" Expr
  | sub: Expr "-" Expr
  )
  | "(" Expr ")"
  | Int
  ;

syntax BoolExpr =
  | "(" BoolExpr ")"
  > non-assoc (
    not: "!" BoolExpr
  )
  > non-assoc (
    lt: Expr "\<" Expr
  | gt: Expr "\>" Expr
  | seq: Expr "\<=" Expr
  | geq: Expr "\>=" Expr
  )
  > left (
    Expr "==" Expr
  | Expr "!=" Expr
  )
  > left (
    and: BoolExpr "&&" BoolExpr
  )
  > left (
    or: BoolExpr "||" BoolExpr
  )
  | Id
  | Bool
  ;

  
syntax Type = "boolean" | "integer" | "string";

lexical Str =  "\"" ([a-zA-Z0-9?\ :])* "\"";

lexical Int 
  = [0-9]+;

lexical Bool = "true" | "false";
