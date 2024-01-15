useful commands:

## Create Parse Tree for File
```
import ParseTree;
import Syntax;
t = parse(#start[Form], |project://sle-rug/examples/tax.myql|, allowAmbiguity=true);
```

## Getting Syntax Highlighting to work
```
import IDE;
main();
```

## Create AST for File

First 2 steps from `Create Parse Tree for File`. Then:

```
import CST2AST;
ast = cst2ast(t);
```

## Checking

```
import IDE;
import ParseTree;
import AST;
import CST2AST;
import Syntax;

t = parse(#start[Form], |project://sle-rug/examples/tax.myql|, allowAmbiguity=true);

ast = cst2ast(t);

check(ast);

```


## Eval


## Create Parse Tree for File
```
import IDE;
import ParseTree;
import AST;
import CST2AST;
import Syntax;

tax = parse(#start[Form], |project://sle-rug/examples/tax.myql|, allowAmbiguity=true);

ast = cst2ast(tax);

import Eval;

env = initialEnv(ast);

// Example eval
eval(ast, input("hasBoughtHouse", vbool(true)), env)

```