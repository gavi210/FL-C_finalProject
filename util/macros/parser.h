#define ASSIGN_VOID_TYPE(Tok)     \
  (Tok).type = VOID_TYPE;

#define DUMP_VAR(VarName)         \
  dumpVar(VarName);

#define DUMP_EXPR(Expr)   \
  printExpressionResult(Expr.type, Expr.value);

#define CHECK_EXPR_BOOL(Expr, Head)     \
  if(Expr.type != BOOL_TYPE)            \
    return PARSING_ERROR;               \
  else ASSIGN_VOID_TYPE(Head)       

#define COPY_TYPE_VALUE(Dest, Src)    \
  Dest.type = Src.type;               \
  Dest.value = Src.value;

#define CHECK_VAR_DECLEARED(Head, Var, VarName)       \
  if(Var == 0) {                                      \
    printf("Var %s is not defined!\n", VarName);      \
    return PARSING_ERROR;                             \
  }                                                   \
  else Head.lexeme = VarName;                      