#define ASSIGN_VOID_TYPE(Tok)     \
  (Tok).type = VOID_TYPE;

#define DUMP_EXPR(Expr)   \
  printExpressionResult(Expr.type, Expr.value); \

#define CHECK_EXPR_BOOL(Expr, Head)     \
  if(Expr.type != BOOL_TYPE)            \
    return PARSING_ERROR;               \
  else ASSIGN_VOID_TYPE(Head)       

#define COPY_TYPE_VALUE_NAME(Dest, Src)    \
  Dest.type = Src.type;               \
  Dest.value = Src.value;             \
  Dest.lexeme = Src.lexeme;   

#define CHECK_VAR_DECLEARED(Head, Var)       \
  if(Var == 0)                                        \
    return PARSING_ERROR;                             \
  else {                                              \
    Head.lexeme = Var->name;                          \
    Head.type = Var->type;                            \
    Head.value = Var->value; }

#define EVAL_ARITH_EXPR_RESULT(Head, Expr1, Expr2, Op, OpChar)            \
  if(typesAreCorrect(Expr1.type, Expr2.type, Op)) {                 \
    Head.type = max(Expr1.type, Expr2.type);                        \
    Head.value = getValue(Op, Head.type, Expr1.value, Expr2.value); \
  }                                                                 \
  else {                                                            \
    printIncompatibleTypesError(OpChar, Expr1.type, Expr2.type);    \
    return PARSING_ERROR;                                           \
  } 


#define EVAL_BOOL_EXPR_RESULT(Head, Expr1, Expr2, Op, OpChar, Value)        \
  if(typesAreCorrect(Expr1.type, Expr2.type, Op)) {                         \
    Head.type = BOOL_TYPE;                                                  \
    Head.value = Value;                                                        \
  }                                                                 \
  else {                                                            \
    printIncompatibleTypesError(OpChar, Expr1.type, Expr2.type);    \
    return PARSING_ERROR;                                           \
  } 