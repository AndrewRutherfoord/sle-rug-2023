module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

keyword MyKeywords = "if" | "else" | "form";

start syntax Form 
  = "form" Id name "{" Component* comps "}"; 

syntax Component = Question | IfThenElse;

// TODO: question, computed question, block, if-then-else, if-then
syntax Question 
  = Str Id id ":" Type type
  | Str Id id ":" Type type "=" Expr expr
  ;


// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)

syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Expr "+" Expr
  | Expr "-" Expr
  | Expr "*" Expr
  | Expr "/" Expr
  | "(" Expr ")"
  | Int
  ;

syntax BoolExpr =
  | "(" BoolExpr ")"
  | BoolExpr "&&" BoolExpr
  | BoolExpr "||" BoolExpr
  | "!" BoolExpr
  | Expr "\>" Expr
  | Expr "\<" Expr
  | Expr "\<=" Expr
  | Expr "\>=" Expr
  | Expr "==" Expr
  | Expr "!=" Expr
  | Id
  | Bool;

  
syntax Type = "boolean" | "integer" | "string";

lexical Str =  "\"" ([a-zA-Z0-9?\ :])* "\"";

lexical Int 
  = [0-9]+;

lexical Bool = "true" | "false";

syntax IfThenElse = If | IfElse;

syntax If = "if" "(" BoolExpr ")" "{" Component* subComps "}";

syntax IfElse 
  = If "else" "{" Component* subComps "}"
  | If "else" IfThenElse;

