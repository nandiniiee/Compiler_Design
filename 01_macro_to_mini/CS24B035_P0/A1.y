%{
#include<iostream>
#include<string>
#include<vector>
#include<map>
#include<cstring>
#include<set>
using namespace std;
struct Macro{
    string name;
    vector<string> prms; //parameters
    string body;
};

map<string, Macro> expressMacro;
map<string, Macro> stmtMacro;
int yylex(void);
void yyerror(const char *s);
void reportError(){
    cout<<"//Failed to parse input code"<<endl;
    exit(0);
}
char* make_string(string s){
    char *p= new char[s.length()+1];
    strcpy(p,s.c_str());
    return p;
}

vector<string> split_prms(string s){
    vector<string> res;
    if(s.empty()){
        return res;
    }
    string cur;
    int depth=0;
    for(char c : s){
        if(c == '(' || c == '['){
            depth++;
        }else if(c == ')' || c == ']'){
            depth--;
        }
        if(c==',' && depth==0){
            res.push_back(cur);
            cur="";
        }else{
            cur+=c;
        }
    }
    if(!cur.empty()){
        res.push_back(cur);
    }
    return res;
}
bool is_id_char(char c){
    return(c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9') || c=='_';
}
string replace_prms(string body, string prms, string arg){
    string result;
    int n=body.length();
    int m=prms.length();
    for(int i=0;i<n;){
        bool match=false;
        if(i+m<=n && body.substr(i,m)==prms){
            bool left_ok = (i==0 || !is_id_char(body[i-1]));
            bool right_ok = (i + m == n || !is_id_char(body[i+m]));

            if(left_ok && right_ok){
                match = true;
            }
        }
        if(match){
            result += arg;
            i += m;
        }
        else{
            result += body[i];
            i++;
        }
    }
    return result;
}
string expand_macro(Macro m, vector<string>args){
    if(m.prms.size()!=args.size()){
        reportError();
    }
    string res=m.body;
    for(int i=0;i<m.prms.size(); i++){
        res=replace_prms(res, m.prms[i], args[i]);
    }
    return res;
}
bool duplicate_prms(const vector<string>&prms){
    for(int i=0;i<prms.size();i++){
        for(int j=i+1; j<prms.size();j++){
            if(prms[i]==prms[j]){
                return true;
            }
        }
    }
    return false;
}
%}

%union{
    int num;
    char *id;
}

/*adding tokens*/
%token CLASS
%token EXTENDS
%token PUBLIC
%token STATIC
%token VOID
%token MAIN
%token STRING
%token INT 
%token BOOLEAN 
%token IF 
%token ELSE 
%token WHILE 
%token RETURN
%token TRUE
%token FALSE
%token THIS
%token NEW
%token PRINT
%token LENGTH

/* macro tokens*/
%token DEFINE_STMT
%token DEFINE_STMT0
%token DEFINE_STMT1
%token DEFINE_STMT2
%token DEFINE_EXPR
%token DEFINE_EXPR0
%token DEFINE_EXPR1
%token DEFINE_EXPR2
%token INVALID
%token <id> IDENTIFIER
%token <num> INTEGER_LITERAL

/*operators*/
%token AND 
%token OR 
%token NE 
%token LE 
%token PLUS 
%token MINUS
%token MULT 
%token DIV 
%token ASSIGN
%token NOT
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/*punctuation*/
%token LBRACE
%token RBRACE
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token SEMICOLON
%token COMMA
%token DOT

%type <id> goal
%type <id> main_class
%type <id> type_declarations
%type <id> type_declaration
%type <id> class_declaration
%type <id> statement
%type <id> statements
%type <id> type
%type <id> var_declarations
%type <id> var_declaration
%type <id> method_declarations
%type <id> method_declaration
%type <id> parameters
%type <id> parameter_list
%type <id> expression
%type <id> or_expression
%type <id> and_expression
%type <id> compare_expression
%type <id> add_expression
%type <id> multiply_expression
%type <id> unary_expression
%type <id> primary_expression
%type <id> postfix_expression
%type <id> arguments
%type <id> argument_list
%type <id> macro_definition
%type <id> macro_definitions
%type <id>macro_parameter_list
%type <id> method_body_item
%type <id> method_body_items

%%
goal:
    macro_definitions main_class type_declarations{
        cout<<$2;
        cout<<$3;
    };

macro_parameter_list:
    IDENTIFIER{
        $$=make_string($1);
    }
    |
    macro_parameter_list COMMA IDENTIFIER{
        string res;
        res=$1;
        res+=",";
        res+=$3;
        $$=make_string(res);
    };

macro_definitions:
    {$$=make_string("");}
    |
    macro_definitions macro_definition{
        $$=make_string("");
    };

macro_definition:
    DEFINE_STMT0 IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE{
        Macro m;
        m.name=$2;
        m.prms={};
        m.body=$6;
        if(stmtMacro.find(m.name) != stmtMacro.end() || expressMacro.find(m.name) != expressMacro.end()){
            reportError();
        }
        stmtMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_STMT1 IDENTIFIER LPAREN IDENTIFIER RPAREN LBRACE statements RBRACE{
        Macro m;
        m.name=$2;
        m.prms.push_back($4);
        m.body=$7;
        if(stmtMacro.find(m.name) != stmtMacro.end() || expressMacro.find(m.name) != expressMacro.end()){
            reportError();
        }
        stmtMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_STMT2 IDENTIFIER LPAREN IDENTIFIER COMMA IDENTIFIER RPAREN LBRACE statements RBRACE{
        Macro m;
        m.name=$2;
        m.prms.push_back($4);
        m.prms.push_back($6);
        if(duplicate_prms(m.prms)){
            reportError();
        }
        m.body=$9;
        if(stmtMacro.find(m.name) != stmtMacro.end() || expressMacro.find(m.name) != expressMacro.end()){
            reportError();
        }
        stmtMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_STMT IDENTIFIER LPAREN macro_parameter_list RPAREN LBRACE statements RBRACE{
        Macro m;
        m.name=$2;
        m.prms=split_prms($4);
        if(m.prms.size()<3){
            reportError();
        }
        if(duplicate_prms(m.prms)){
            reportError();
        }
        m.body=$7;
        if(stmtMacro.find(m.name) != stmtMacro.end() || expressMacro.find(m.name) != expressMacro.end()){
            reportError();
        }
        stmtMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_EXPR0 IDENTIFIER LPAREN RPAREN LPAREN expression RPAREN{
        Macro m;
        m.name=($2);
        m.prms={};
        m.body="(";
        m.body+=$6;
        m.body+=")";
        if(expressMacro.find(m.name) != expressMacro.end() || stmtMacro.find(m.name) != stmtMacro.end()){
            reportError();
        }
        expressMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_EXPR1 IDENTIFIER LPAREN IDENTIFIER RPAREN LPAREN expression RPAREN{
        Macro m;
        m.name=($2);
        m.prms.push_back($4);
        m.body="(";
        m.body+=$7;
        m.body+=")";
        if(expressMacro.find(m.name) != expressMacro.end() || stmtMacro.find(m.name) != stmtMacro.end()){
            reportError();
        }
        expressMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_EXPR2 IDENTIFIER LPAREN IDENTIFIER COMMA IDENTIFIER RPAREN LPAREN expression RPAREN{
        Macro m;
        m.name=($2);
        m.prms.push_back($4);
        m.prms.push_back($6);
        if(duplicate_prms(m.prms)){
            reportError();
        }
        m.body="(";
        m.body+=$9;
        m.body+=")";
        if(expressMacro.find(m.name) != expressMacro.end() || stmtMacro.find(m.name) != stmtMacro.end()){
            reportError();
        }
        expressMacro[m.name]=m;
        $$=make_string("");
    }
    |
    DEFINE_EXPR IDENTIFIER LPAREN macro_parameter_list RPAREN LPAREN expression RPAREN{
        Macro m;
        m.name=$2;
        m.prms= split_prms($4);
        if(m.prms.size()<3){
            reportError();
        }
        if(duplicate_prms(m.prms)){
            reportError();
        }
        m.body="(";
        m.body+=$7;
        m.body+=")";
        if(expressMacro.find(m.name) != expressMacro.end() || stmtMacro.find(m.name) != stmtMacro.end()){
            reportError();
        }
        expressMacro[m.name]=m;
        $$=make_string("");
    };

main_class:
    CLASS IDENTIFIER LBRACE PUBLIC STATIC VOID MAIN LPAREN STRING LBRACKET RBRACKET IDENTIFIER RPAREN LBRACE PRINT LPAREN expression RPAREN SEMICOLON RBRACE RBRACE
    {
        string res;
        res="class ";
        res+=$2;
        res+=" {\n";
        res+="    public static void main(String[] ";
        res+=$12;
        res+=") {\n";
        res+="        System.out.println(";
        res+=$17;
        res+=");\n";
        res+="    }\n";
        res+="}\n";
        $$=make_string(res);
    };

statement:
    LBRACE statements  RBRACE{
        string res;
        res="{\n";
        res+=$2;
        res+="}\n";
        $$=make_string(res);
    }
    |
    PRINT LPAREN expression RPAREN SEMICOLON{
        string res;
        res="System.out.println(";
        res+=$3;
        res+=");\n";
        $$=make_string(res);
    }
    |
    IDENTIFIER ASSIGN expression SEMICOLON{
        string res;
        res=$1;
        res+=" = ";
        res+=$3;
        res+=";\n";
        $$=make_string(res);
    }
    |
    IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression SEMICOLON{
        string res;
        res=$1;
        res+="[";
        res+=$3;
        res+="]=";
        res+=$6;
        res+=";\n";
        $$=make_string(res);
    }
    |
    IDENTIFIER LPAREN arguments RPAREN SEMICOLON{
        string name=$1;
        if(stmtMacro.find(name)==stmtMacro.end()){
            reportError();
        }else{
            Macro m=stmtMacro[name];
            vector<string> args=split_prms($3);
            if(args.size()!=m.prms.size()){
                reportError();
            }else{
                string res=expand_macro(m, args);
                $$=make_string(res);
            }
        }
    }
    |
    IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
        string res;
        res="if (";
        res+=$3;
        res+=") ";
        res+=$5;
        $$=make_string(res);
    }
    |
    IF LPAREN expression RPAREN statement ELSE statement{
        string res;
        res="if (";
        res+=$3;
        res+=") ";
        res+=$5;
        res+="else ";
        res+=$7;
        $$=make_string(res);
    }
    |
    WHILE LPAREN expression RPAREN statement{
        string res;
        res="while (";
        res+=$3;
        res+=") ";
        res+=$5;
        $$=make_string(res);
    };

statements:
    {$$=make_string("");}
    |
    statements statement{
        string res;
        res=$1;
        res+=$2;
        $$=make_string(res);
    };

type_declarations:
    {$$=make_string("");}
    |
    type_declarations type_declaration{
        string res;
        res=$1;
        res+=$2;
        $$=make_string(res);
    };

type_declaration:
    class_declaration{
        $$=$1;
    };

class_declaration:
    CLASS IDENTIFIER LBRACE var_declarations method_declarations RBRACE{
        string res;
        res="class ";
        res+=$2;
        res+=" {\n";
        res+=$4;
        res+=$5;
        res+= "}\n";
        $$=make_string(res);
    }
    |
    CLASS IDENTIFIER EXTENDS IDENTIFIER LBRACE var_declarations method_declarations RBRACE{
        string res;
        res="class ";
        res+=$2;
        res+=" extends ";
        res+=$4;
        res+=" {\n";
        res+=$6;
        res+=$7;
        res+= "}\n";
        $$=make_string(res);
    };

type: 
    INT LBRACKET RBRACKET{
        $$=make_string("int[]");
    }
    |
    BOOLEAN{
        $$=make_string("boolean");
    }
    |
    INT{
        $$=make_string("int");
    }
    |
    IDENTIFIER{
        $$=make_string($1);
    };
method_body_item:
    var_declaration{ $$=$1; }
    |
    statement{ $$=$1; };

method_body_items:
    {$$=make_string("");}
    |
    method_body_items method_body_item{
        string res;
        res=$1;
        res+=$2;
        $$=make_string(res);
    };

var_declaration:
    INT IDENTIFIER SEMICOLON{
        string res;
        res="int ";
        res+=$2;
        res+=";\n";
        $$=make_string(res);
    }
    |
    BOOLEAN IDENTIFIER SEMICOLON{
        string res;
        res="boolean ";
        res+=$2;
        res+=";\n";
        $$=make_string(res);
    }
    |
    INT LBRACKET RBRACKET IDENTIFIER SEMICOLON{
        string res;
        res="int[] ";
        res+=$4;
        res+=";\n";
        $$=make_string(res);
    }
    |
    IDENTIFIER IDENTIFIER SEMICOLON{
        string res;
        res=$1;
        res+=" ";
        res+=$2;
        res+=";\n";
        $$=make_string(res);
    };

var_declarations:
    {$$=make_string("");}
    |
    var_declarations var_declaration{
        string res;
        res=$1;
        res+=$2;
        $$=make_string(res);
    };

method_declarations:
    {
        $$=make_string("");
    }
    |
    method_declarations method_declaration{
        string res;
        res=$1;
        res+=$2;
        $$=make_string(res);
    };

parameters:
   {$$= make_string("");}
   |
   parameter_list{
    $$=$1;
   };

method_declaration:
    PUBLIC type IDENTIFIER LPAREN parameters RPAREN LBRACE method_body_items RETURN expression SEMICOLON RBRACE{
        string res;
        res="    public ";
        res+=$2;
        res+=" ";
        res+=$3;
        res+="(";
        res+=$5;
        res+=") {\n";
        res+=$8;
        res+="        return ";
        res+=$10;
        res+=";\n";
        res+="    }\n";
        $$=make_string(res);
    };

parameter_list:
   type IDENTIFIER{
    string res;
    res=$1;
    res+=" ";
    res+=$2;
    $$= make_string(res);
   }
   |
   parameter_list COMMA type IDENTIFIER{
    string res;
    res=$1;
    res+=", ";
    res+=$3;
    res+=" ";
    res+=$4;
    $$=make_string(res);
   };

expression:
   or_expression{
    $$=$1;
   };

or_expression:
   and_expression{
    $$=$1;
   }
   | or_expression OR and_expression{
    string res;
    res=$1;
    res+=" || ";
    res+=$3;
    $$=make_string(res);
   };

and_expression:
  compare_expression{
    $$=$1;
  }
  |
  and_expression AND compare_expression{
    string res;
    res=$1;
    res+=" && ";
    res+=$3;
    $$=make_string(res);
  };

compare_expression: 
  add_expression{
    $$=$1;
  }
  |
  add_expression LE add_expression{
    string res;
    res=$1;
    res+=" <= ";
    res+= $3;
    $$=make_string(res);
  }
  |
  add_expression NE add_expression{
    string res;
    res=$1;
    res+=" != ";
    res+=$3;
    $$=make_string(res);
  };

add_expression:
  multiply_expression{
    $$=$1;
  }
  |
  add_expression PLUS multiply_expression{
    string res;
    res=$1;
    res+=" + ";
    res+=$3;
    $$=make_string(res);
  }
  |
  add_expression MINUS multiply_expression{
    string res;
    res=$1;
    res+=" - ";
    res+=$3;
    $$=make_string(res);
  };

multiply_expression:
    postfix_expression{
        $$=$1;
    }
    |
    multiply_expression MULT postfix_expression{
        string res;
        res=$1;
        res+=" * ";
        res+=$3;
        $$=make_string(res);
    }
    |
    multiply_expression DIV postfix_expression{
        string res;
        res=$1;
        res+=" / ";
        res+=$3;
        $$=make_string(res);
    };

postfix_expression:
    unary_expression{
        $$=$1;
    }
    |
    postfix_expression LBRACKET expression RBRACKET{
        string res;
        res=$1;
        res+="[";
        res+=$3;
        res+="]";
        $$=make_string(res);
    }
    |
    postfix_expression DOT LENGTH{
        string res;
        res=$1;
        res+=".length";
        $$=make_string(res);
    }
    |
    postfix_expression DOT IDENTIFIER LPAREN arguments RPAREN{
        string res;
        res=$1;
        res+=".";
        res+=$3;
        res+="(";
        res+=$5;
        res+=")";
        $$=make_string(res);
    };

unary_expression:
  NOT unary_expression{
    string res;
    res="!";
    res+=$2;
    $$=make_string(res);
  }
  |
  primary_expression{
    $$=$1;
  };
primary_expression:
    INTEGER_LITERAL{
        string res;
        res=to_string($1);
        $$=make_string(res);
    }
    |
    IDENTIFIER{
        $$=make_string($1);
    }
    |
    TRUE{
        $$=make_string("true");
    }
    |
    FALSE{
        $$=make_string("false");
    }
    |
    THIS{
        $$=make_string("this");
    }
    |
    NEW INT LBRACKET expression RBRACKET{
        string res;
        res="new int[";
        res+=$4;
        res+="]";
        $$=make_string(res);
    }
    |
    NEW IDENTIFIER LPAREN RPAREN{
        string res;
        res="new ";
        res+=$2;
        res+="()";
        $$=make_string(res);
    }
    |
    LPAREN expression RPAREN{
        string res;
        res="(";
        res+=$2;
        res+=")";
        $$=make_string(res);
    }
    |
    IDENTIFIER LPAREN arguments RPAREN{
        string name=$1;
        if(expressMacro.find(name)==expressMacro.end()){
            reportError();
        }else{
            Macro m=expressMacro[name];
            vector<string> args=split_prms($3);
            if(args.size()!=m.prms.size()){
               reportError();
            }else{
                string res=expand_macro(m, args);
                $$=make_string(res);
            }
        }
    };

arguments:
   {$$=make_string("");}
   |
   argument_list{
    $$=$1;
   };

argument_list:
   expression{
    $$=$1;
   }
   |
   argument_list COMMA expression{
    string res;
    res=$1;
    res+=", ";
    res+=$3;
    $$=make_string(res);
   };
%%

extern int yylineno;
extern char *yytext;

void yyerror(const char *s){
    reportError();
}
int main(){
    yyparse();
    return 0;
}
