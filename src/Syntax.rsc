module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = NormQuestion | CompQuestion | IfThenElse;
syntax NormQuestion = (Str Id id ":" Type type);
syntax CompQuestion = (NormQuestion "=" Expr expr);


// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)

syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Expr "+" Expr
  | Expr "-" Expr
  | Expr "*" Expr
  | Expr "/" Expr
  | Expr "&&" Expr
  | Expr "||" Expr
  | "!" Expr
  | Expr "\>" Expr
  | Expr "\<" Expr
  | Expr "\<=" Expr
  | Expr "\>=" Expr
  | Expr "==" Expr
  | Expr "!=" Expr
  | "(" Expr ")"
  | Bool
  | Int
  | Str
  ;
  
syntax Type = "boolean" | "integer" | "string";

lexical Str =  "\"" ([a-zA-Z0-9?\ :])* "\"";

lexical Int 
  = [0-9]+;

lexical Bool = "true" | "false";

syntax IfThenElse = If | IfElse;

syntax If = "if" "(" Expr ")" "{" Question* "}";

syntax IfElse = If "else" "{" Question* "}";

