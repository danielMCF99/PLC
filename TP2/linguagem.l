%{

%}
%option noyywrap

%%
[{}+\-*/%;,<>()]                        { return(yytext[0]); } 

(?i:declaracoes)                        { return(DECLARACOES); }

(?i:inteiro)                            { return(INTEIRO); }
((?i:arr)\-(?i:inteiro))                { return(ARRINTEIRO); }

(?i:verdadeiro)                         { yylval.valI = atoi(yytext); return(TRUE);}
(?i:falso)                              { yylval.valI = atoi(yytext); return(FALSE);}

(?i:inicio)                             { return(INICIO); }

(?i:escrever)                           { return(ESCREVER); }
(?i:ler)                                { return(LER); }

(?i:se)                                 { contaIF++; return(SE); }
(?i:senao)                              { return(SENAO); }

(?i:para)                               { contaFOR++; return(PARA); }
(?i:ate)                                { return(ATE); }
(?i:fazer)                              { return(FAZER); }

">>"                                    { return(GT); }
"<<"                                    { return(LT); }
"=="                                    { return(EQ); }
">="                                    { return(GE); }
"<="                                    { return(LE); }
"#"                                     { return(NE); }

(?i:e)                                  { return(E); }
(?i:ou)                                 { return(OU); }
  
(?i:fim)                                { return(FIM); }

\"[a-zA-Z0-9 =:\\n,]+\"                 { yylval.valS = strdup(yytext); return(FRASE); }

[a-zA-z]+                               { yylval.valS = strdup(yytext); return(ID); }
[0-9]+                                  { yylval.valI = atoi(yytext); return(NUM); }

.|\n                                    { ; }
%%

