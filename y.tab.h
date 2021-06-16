/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     BOOL_VAL = 258,
     INT_VAL = 259,
     FLOAT_VAL = 260,
     IDENTIFIER = 261,
     DOUBLE = 262,
     INT = 263,
     BOOLEAN = 264,
     WHILE = 265,
     IF = 266,
     ELSE = 267,
     PRINT = 268,
     EXIT_SUB_SCOPE = 269,
     ENTER_SUB_SCOPE = 270,
     ASSIGN_OP = 271,
     SMALLER_EQ_THAN = 272,
     BIGGER_EQ_THAN = 273,
     NOT_EQUAL_TO = 274,
     EQUAL_TO = 275,
     SMALLER_THAN = 276,
     BIGGER_THAN = 277,
     NOT = 278,
     PLUS = 279,
     MINUS = 280,
     DIV = 281,
     MOLT = 282,
     C_PAR = 283,
     O_PAR = 284,
     UMINUS = 285,
     IFX = 286,
     LIST_STMT = 287
   };
#endif
/* Tokens.  */
#define BOOL_VAL 258
#define INT_VAL 259
#define FLOAT_VAL 260
#define IDENTIFIER 261
#define DOUBLE 262
#define INT 263
#define BOOLEAN 264
#define WHILE 265
#define IF 266
#define ELSE 267
#define PRINT 268
#define EXIT_SUB_SCOPE 269
#define ENTER_SUB_SCOPE 270
#define ASSIGN_OP 271
#define SMALLER_EQ_THAN 272
#define BIGGER_EQ_THAN 273
#define NOT_EQUAL_TO 274
#define EQUAL_TO 275
#define SMALLER_THAN 276
#define BIGGER_THAN 277
#define NOT 278
#define PLUS 279
#define MINUS 280
#define DIV 281
#define MOLT 282
#define C_PAR 283
#define O_PAR 284
#define UMINUS 285
#define IFX 286
#define LIST_STMT 287




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 37 "parser.y"
{
       char* lexeme; // text for identifiers
       double value; // value for tokens
       int type;
       struct parse_tree_node parse_tree_node_info;
       }
/* Line 1529 of yacc.c.  */
#line 120 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;
