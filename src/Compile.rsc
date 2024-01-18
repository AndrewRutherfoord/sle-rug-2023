module Compile

import AST;
import Resolve;
import IO;

str js_file = "./idk.js";
str html_file = "./idk.html";

data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;
alias VEnv = map[str name, Value \value];

int defaultInt() = 0;
bool defaultBool() = false;
str defaultStr() = "";

Value defaultValue(AType t) {
  switch (t) {
    case integer(): return vint(defaultInt());
    case boolean(): return vbool(defaultBool());
    case string(): return vstr(defaultStr());
    default: throw "Unsupported type <t>";
  }
}

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  // Not using writeHTMLString because it of custom components not being supported. We are using Vue components.
  writeFile(f.src[extension="html"].top, form2html(f));
}

str form2html(AForm f) {
  return "\<!DOCTYPE html\>
  '\<html lang=\"en\"\>
  '
  '\<head\>
  '  \<meta charset=\"UTF-8\"\>
  '  \<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"\>
  '  \<title\>Document\</title\>
  '  \<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN\" crossorigin=\"anonymous\"\>
  '\</head\>
  '
  '\<body\>
  '  \<script src=\"https://unpkg.com/vue@3/dist/vue.global.js\"\>\</script\>
  '
  '  \<div id=\"app\"\>
  '  \<form class=\"container\"\>
  '<components2Html(f.components)>
  '  \</form\>
  '  \</div\>
  '
  '  \<script type=\"module\" src=\"<f.src[extension="js"].file>\"\>\</script\>
  '\</body\>
  '
  '\</html\>
  ";
}

str simpleQuestion2html(str id, str label, AType varType) {
  switch (varType) {
    case integer(): return "    \<int-input  id=\"<id>\" label=<label> v-model=\"<id>\"\>\</int-input\>\n";
    case boolean(): return "    \<bool-input id=\"<id>\" label=<label> v-model=\"<id>\"\>\</bool-input\>\n";
    case string(): return "     \<str-input  id=\"<id>\" label=<label> v-model=\"<id>\"\>\</str-input\>\n";
    default: throw "Unsupported type <varType>";
  }
}

str cond2html(ABoolExpr be) {
  return bexprToStr(be);
}


str components2Html(list[AComponent] cs) {
  result = "";
  for (c <- cs) {
    switch(c) {
      case questionComponent(AQuestion q, src = loc u):
        result = result + question2Html(q);
      case conditionalComponent(AConditional cc, src = loc u):
        result = result + conditional2Html(cc);
      default : 
        result = result;
    }
  }
  return result;
}

str conditional2Html(AConditional c) {
  result = "";
  switch(c) {
      case ifThen(ABoolExpr cond, list[AComponent] then, src = loc u):
        result = result + "\<div v-if=\"<cond2html(cond)>\"\>
          '<components2Html(then)>
          '\</div\>\n";
      case ifThenElse(ABoolExpr cond, list[AComponent] then, list[AComponent] elseC, src = loc u):
        result = result + "\<div v-if=\"<cond2html(cond)>\"\>
          '<components2Html(then)>
          '\</div\>\n
          '\<div v-else\>\n
          '<components2Html(elseC)>
          '\</div\>\n";
      default : 
        result = result;
  }
  return result;
}

str computedQuestion2Html(str id, str label, AType varType, AExpr expr) {
  switch (varType) {
    case integer(): return "    \<computed-input id=\"<id>\" label=<label> v-bind:value=\"<id>\"\>\</computed-input\>\n";
    case boolean(): return "    \<computed-input id=\"<id>\" label=<label> v-bind:value=\"<id>\"\>\</computed-input\>\n";
    case string(): return  "    \<computed-input id=\"<id>\" label=<label> v-bind:value=\"<id>\"\>\</computed-input\>\n";
    default: throw "Unsupported type <varType>";
  }
}

str question2Html(AQuestion q) {
  result = "";
  switch(q) {
    case simpleQuestion(strg(str label), ref(id(str sid), src = loc u), AType varType, src = loc q):
      result = result + simpleQuestion2html(sid, label, varType);
    case computedQuestion(strg(str label), ref(id(str sid), src= loc u), AType varType, AExpr expr, src=loc q):
      result = result + computedQuestion2Html(sid, label, varType, expr);
    default : 
        result = result;
  }
  return result;
}

str form2js(AForm f) {
  return "import { StrInput, BoolInput, IntInput, ComputedInput } from \'./components.js\';
    'const { createApp } = Vue;
  '
  'createApp({
  '  components: {
  '    StrInput,
  '    BoolInput,
  '    IntInput,
  '    ComputedInput,
  '  },
  '  data() {
  '    return {
  '      <fields2js(f)>    }
  '  },
  '  computed: {
  '    <computed2js(f)>
  '  },
  '}).mount(\"#app\");";
}

str fields2js(AForm f) {
  VEnv env = ();
  visit(f) {
  	case simpleQuestion(strg(str label), ref(AId id, src = loc u), AType varType, src = loc q):
  		env = env + (id.name: defaultValue(varType));
  }
  str result = "";
  for (eVar <- env) {
    visit(env[eVar]) {
      case vint(int v):
        result += eVar + ": <v>,\n";
      case vstr(str s):
        result += eVar + ": <s>,\n";
      case vbool(bool b):
        result += eVar + ": <b>,\n";
    }
  }
  return result;
}

str bexprToStr(ABoolExpr be) {
  switch (be) {
    case boolean(bool bv): return "<bv>";
    case bref(id(str x)): return "<x>";
    case and(ABoolExpr bLeft, ABoolExpr bRight):
      return "<bexprToStr(bLeft)> && <bexprToStr(bRight)>";
    case or(ABoolExpr bLeft, ABoolExpr bRight):
      return "<bexprToStr(bLeft)> || <bexprToStr(bRight)>";
    case gt(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> \> <exprToStr(nRight, false)>";
    case lt(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> \< <exprToStr(nRight, false)>";
    case geq(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> \>= <exprToStr(nRight, false)>";
    case leq(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> \<= <exprToStr(nRight, false)>";
    case eq(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> == <exprToStr(nRight, false)>";
    case neq(AExpr nLeft, AExpr nRight):
      return "<exprToStr(nLeft, false)> != <exprToStr(nRight, false)>";
    case parentheses(ABoolExpr b):
      return "(<bexprToStr(b)>)";
    case not(ABoolExpr b):
      return "!(<bexprToStr(b)>)";
    
    default: throw "Unsupported expression <be>";
  }
}

str exprToStr(AExpr e, bool withThis) {
  switch (e) {
    case ref(id(str x)): {
      if (withThis) {
        return "this.<x>";
      } else {
        return "<x>";
      }
    }
    case intgr(int n): return "<n>";
    case add(AExpr e1, AExpr e2): 
      return "<exprToStr(e1, withThis)> + <exprToStr(e2, withThis)>";
    case sub(AExpr e1, AExpr e2):
      return "<exprToStr(e1, withThis)> - <exprToStr(e2, withThis)>";
    case mul(AExpr e1, AExpr e2):
      return "<exprToStr(e1, withThis)> * <exprToStr(e2, withThis)>";
    case div(AExpr e1, AExpr e2):
      return "<exprToStr(e1, withThis)> / <exprToStr(e2, withThis)>";
    case inBetweenParantherses(AExpr e): 
      return "(<exprToStr(e, withThis)>)";    
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}

str computedField2js(str id, AExpr e ){ 
  return id + "() {
    '  return <exprToStr(e, true)>
    '},\n";
}
str computed2js(AForm f) {
  VEnv env = ();
  str result = "";
  visit(f) {
    case computedQuestion(strg(str label), ref(id(str sid), src = loc u), AType varType, AExpr e, src = loc q):
    	result = result + computedField2js(sid,e);
  }
  return result;
}