%{
	#include "y.tab.h"
	#include <iostream>
    #include <vector>
    #include <algorithm>
    #include <string.h>
    #include <map>  
	using namespace std;
	extern FILE *yyin;
	extern int yylex();
    extern int linenumber;
    extern int tabcount;
	void yyerror(string s);
    string int_typestr(int);
    map<int,vector<string>> variableMap;
    map<string,int> current_var;

    int loopstartcheckher=0;
    bool ifopened=false;
    int counter_if=0;

    bool compareFunction(const string& a, const string& b) {
        if (a < b) {
            return true;
        } else {
            return false;
        }
    }

%}

%union
{  
    struct var{
	    char* name;
	    int type;
    }; 
    int tab;
    char* str;
    var data;

}



%token LINENUMBER  EQUAL  IF COLUMN ELIF  ELSE
%token <tab> TAB
%token <str> VARIABLE STR INT FLT OPERATOR CONDITION
%type <str>  statements assignment ifelse condution
%type <data> expr type statement
%left OPERATOR LINENUMBER
%start program
%%
program:
    statements  
    {
    string statement = string($1);


    cout << "void main()\n{";
    for(int i=0;i<3;i++)
    {
        if(variableMap[i].size()==0)
            continue;
        string type;
        if(i==0)
            type="int";
        else if(i==1)
            type="float";
        else if(i==2)
            type="string";
        cout << "\n\t"<<type<<" ";

        sort(variableMap[i].begin(),variableMap[i].end(),compareFunction);

        for(int j=0;j<variableMap[i].size();j++)
            if(j!=variableMap[i].size()-1)
            cout << (variableMap[i])[j]<<"_"<<int_typestr(i)<<",";
            else
            cout << (variableMap[i])[j]<<"_"<<int_typestr(i);
        cout << ";";

    }
    cout <<endl;
    cout << "\n";
    bool f=true;
    for (int i=0;statement[i]!='\0';i++){
        if (statement[i]=='\n')
            {
                cout<<"\n";
                f=true;
            }
        else
            {
                if (f)
                    cout<<"\t";
                cout<<statement[i];
                f=false;
            }
    }
    cout << "}"<<endl;
    
}

statements:
    TAB statement
    {   
        string temp;
        int i = 0;
        while (i < $1) {
            temp += "\t";
            ++i;
        }
        temp = temp + string($2.name);
        $2.name = strdup(temp.c_str());

        
        if(ifopened){
            if(counter_if == $1)
            {
            ifopened = false;
            }
            else{
                cout << "tab inconsistency in line "<< linenumber << endl;
                return 0;
            }


        }

        
        else if ($1 > counter_if )
        {
            cout << "tab inconsistency in line "<< linenumber << endl;
            return 0;
        }
        else if($1 < counter_if)
        {
            string combined;
            int differences = counter_if - $1;
            for(int j=0;j<differences;j++)
            {
                for(int i =0 ;i<counter_if-1-j;i++)
                combined+="\t";
                combined=combined+ "}\n";
            }
            combined+=string($2.name);
            $2.name = strdup(combined.c_str());
            counter_if = $1;

        }
        if($2.type)
        {
            counter_if++;
            ifopened =true;
            string temp1="\n";
            for(int i=0;i<$1;i++)
            temp1+="\t";

            temp1 = string($2.name) +temp1+ "{";
            $2.name = strdup(temp1.c_str());
        }

    
    
        temp = string($2.name);
        $$ = strdup(temp.c_str());
        
    }
    |
    statement
    {
    if (counter_if > 0) {
        string temp;
        int i = 0;
        while (i < counter_if - 1) {
            temp += "\t";
            ++i;
        }

        temp = temp + "}\n" + string($1.name);
        $1.name = strdup(temp.c_str());

        counter_if = 0;
    }

	//cout << ifopened << endl;
    if(ifopened){
        cout << "error in line "<<linenumber<<": at least one line should be inside if/elif/else block "<<endl;
        return 0;
    }
    if($1.type)
    {
        counter_if++;
        ifopened = true;
        string combined1 = string($1.name) + "\n{";
        $1.name = strdup(combined1.c_str());
    }
    else{
	   ifopened=false;
	   	}
    
    string temp = string($1.name);
    $$ = strdup(temp.c_str());
    }
    |
    statements LINENUMBER statements
    {
        if(string($3)!="\n"){
            string combined = string($$)+"\n"+string($3);
		    $$ = strdup(combined.c_str());
        }
    }
statement: 
    assignment
    {
        $$.type = false;
        $$.name = $1;
    }
    |
    ifelse
    {
       $$.type = true;
       $$.name = $1;
    }
	|
	 {
        $$.type = false;
        $$.name = strdup("");
     }
    ;
assignment: VARIABLE EQUAL expr
    {
        string temp = string($1);
        // vectorun içinde  o vaar yoksa ekle
        std::vector<string>::iterator it;
        short i = $3.type;
        if (!(std::find(variableMap[i].begin(), variableMap[i].end(),temp)!=variableMap[i].end()))
            variableMap[i].push_back(temp);
        
        //real vectorunde de ekle
        current_var[temp] = $3.type;

        string c= string($1)+"_"+int_typestr(current_var[$1]) +" = " + $3.name+";";
        $$ = strdup(c.c_str());
        

    }
;
ifelse: 
    IF condution COLUMN
	{
		loopstartcheckher = 1;
        string combined = "if" + string($2);
        $$ = strdup(combined.c_str());

	}
    |
    ELIF condution COLUMN
    {
        if(counter_if ==0 ){
            cout << "else without if in line "<< linenumber << endl; 
            return 0 ;
        }
		else if(loopstartcheckher!=1)
		{
			cout << "elif after else in line " << linenumber<<endl;
			return 0;
		}
        string temp = "else if" + string($2);
        $$ = strdup(temp.c_str());
    }
    |
    ELSE COLUMN
	{
		loopstartcheckher = 0;
		if(counter_if ==0){
            cout << "else without if in line "<< linenumber << endl; 
            return 0 ;
        }
        string temp = "else";
        $$ = strdup(temp.c_str());
	}
    ;

condution: expr CONDITION expr
    {
       
        if (($3.type == 2 && $1.type != 2) || ($1.type == 2 && $3.type != 2)) {
            cout << "comparison type mismatch in line " << linenumber << endl;
            return 0;
        }
        string temp = "(" + string($1.name) + " " + $2 + " " + string($3.name) + ")";
        $$ = strdup(temp.c_str());
    }
    ;

expr:VARIABLE
    {
        int ty = current_var[string($1)];
        $$.type = ty;
        string combined = string($1)+"_"+int_typestr(ty);
        $$.name = strdup(combined.c_str());
    }
    |
    type
    {
        $$.type=$1.type;
        string combined =string($1.name);        
        $$.name = strdup(combined.c_str());
    }
    |
    expr OPERATOR expr
    {
        
        string combined = string($$.name)+" "+$2+" " +string($3.name);
		$$.name = strdup(combined.c_str());
        //cout <<  $1.name << " - " << $3.name << endl;
        
		if($1.type==$3.type)
			$$.type=$1.type;
		else if( $1.type==1 && $3.type==0 )
			$$.type=1;
        else if( $1.type==0 && $3.type==1 )
			$$.type=1;
		else{
			cout << "type mismatch in line "<< linenumber <<endl;
			return 0;
		}
        //cout << "ilk: " << $1 << "iki" << $3 <<endl;

    }
    ;


type:
    INT
    {
        string temp = string($1);
		$$.name = strdup(temp.c_str());
        $$.type = 0;
    }   
    |
    FLT
    {
        string temp = string($1);
		$$.name = strdup(temp.c_str());
        $$.type = 1;
    }
    |
    STR
    {   
        string temp = string($1);
		$$.name = strdup(temp.c_str());
        $$.type = 2;
    }
    ;



%%

string int_typestr(int a){

    if(a==0)
        return "int";
    if(a==1)
        return "flt";
    else
        return "str";


}


void yyerror(string s){
	cout<<"error "<< s<<endl;

}
int yywrap(){
	return 0;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}





