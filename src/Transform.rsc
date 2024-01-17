module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import IO;
import ParseTree;
import Node;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  list[AComponent] comps = [];
  for (AComponent c <- f.components) {
    comps += flatten(c, boolean(true));
  }
  return form(f.name, comps, src=f.src);
}

list[AComponent] flatten(AComponent c, ABoolExpr g) {
  list[AComponent] comps = [];
  switch (c) {
    case questionComponent(q) : comps += flatten(q, g);
    case conditionalComponent(cond) : comps += flatten(cond, g);
  }
  return comps;
}

list[AComponent] flatten(AConditional c, ABoolExpr g) {
  list[AComponent] comps = [];
  switch (c) {
    case ifThen(ABoolExpr guard, list[AComponent] cs) :  comps += flatten(cs, and(g, guard));
    case ifThenElse(ABoolExpr guard, list[AComponent] cs, list[AComponent] ecs) : {
      comps += flatten(cs, and(g, guard));
      comps += flatten(ecs, and(g, not(guard)));
    }
  }
  return comps;
}

list[AComponent] flatten(list[AComponent] cs, ABoolExpr g) {
  list[AComponent] comps = [];
  for (AComponent c <- cs) {
    comps += flatten(c, g);
  }
  return comps;
}

list[AComponent] flatten(AQuestion q, ABoolExpr g) {
  return [conditionalComponent(ifThen(g, [questionComponent(q)]))];
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, str oldName, str newName) {
  loc useOrDef = getRef(f, oldName);
  if(useOrDef == |dummy:///|) {
    return f;
  }
  RefGraph refs = resolve(cst2ast(f.top));
  UseDef useDef = refs.useDef;
  set[loc] toRename = {useOrDef};

  if(useOrDef in refs.uses<0>) {
    if(<useOrDef, loc def> <- useDef) {
      toRename = toRename + {def};
      toRename += { u | <loc u, def> <- useDef };
    }
  } else {
    toRename += { u | <useOrDef, loc u> <- useDef };
  }
  bprintln(toRename);
   return visit(f) {
      case Id id => refactorId(id, "<newName>", toRename)
   }
} 

loc getRef(start[Form] f, str nameToFind) {
  RefGraph refs = resolve(cst2ast(f.top));
  Use useDef = refs.uses;

  for(<loc use, str name> <- useDef) {
    bprintln(name);
    if(name == nameToFind) {
      return use;
    }
  }
  return |dummy:///|;
}


Id refactorId(Id id, str newName, set[loc] usesAndDefs) {
    
	if (id.src in usesAndDefs) {
	   	Id newId = parse(#Id, "<newName>");
		newId = setAnnotations(newId, ("loc": id@\loc));
    bprintln("renamed");
		return newId;
	} else {
		return id;
	}
 }
 
 
 

