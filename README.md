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
