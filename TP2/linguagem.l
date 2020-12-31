%{

%}
%x ARRAY 
%option noyywrap

%%
[{}+\-*/%;,<>()]                        { return(yytext[0]); }


(?i:declaracoes(\n)?)                   { return(DECLARACOES); }

(?i:inteiro)                            { return(INTEIRO); }
((?i:arr)\-(?i:inteiro))                { return(ARRINTEIRO); }

(?i:verdadeiro)                         { yylval.valI = atoi(yytext); return(TRUE);}
(?i:falso)                              { yylval.valI = atoi(yytext); return(FALSE);}

(?i:inicio)                             { return(INICIO); }

(?i:escrever)                           { return(ESCREVER); }
(?i:ler)                                { return(LER); }

(?i:se)                                 { return(SE); }
(?i:senao)                              { return(SENAO); }

(?i:para)                               { return(PARA); }
(?i:fazer)                              { return(FAZER); }

(?i:fim)                                { return(FIM); }

[a-zA-z]+                               { return(ID); }
[0-9]+                                  { yylval.valI = atoi(yytext); return(NUM);}

.|\n                                    { ; }
%%

