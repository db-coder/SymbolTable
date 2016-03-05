#include <iostream>
#include <string>
#include <algorithm>
#include <vector>
#include <stack>
#include <cstdlib>
#include "Parserbase.h"
using namespace std;

extern int l_no;
class type {
	public:
		string name;
		type *t;
		virtual void print()
		{
			cout << name ;
			if(t != 0)t->print();
		}
};

class array_type : public type
{
	public:
		int dim;
		array_type(type *t1)
		{
			name = "array";
			t = t1;
		}
};

class pointer_type : public type
{
	public:
		pointer_type(type *t1)
		{
			name = "pointer";
			t = t1;
		}
};	

class base_type : public type //float, int, void, struct
{
	public:
		base_type(string s)
		{
			name = s;
			t = 0;
		}
};
namespace
{
bool equal(type *t1, type *t2) //check, seriously!
	{
		if(t1 == 0 || t2 == 0)
			return t1 == t2;
		
		else if(t1->name == "pointer")
		{
			if(t2->name == "pointer" || t2->name == "array")
				if(!equal(t1->t,t2->t)){
					return 0;
				}
			else 
			{
				return 0;
			}
		}
		else if(t1->name == "array")
		{
			if(t2->name == "pointer" || t2->name == "array")
				if(!equal(t1->t,t2->t))
				{
					return 0;
				}	
			else 
			{
				return 0;
			}
		}
		else 
		{
			return t1->name == t2->name; //for structs
		}
		return 1;
	}

	void err(int code)
	{
		cerr << "Error: ";
		if(code == 1)cerr << "struct redeclaration";
		if(code == 2)cerr << "struct not found";
		if(code == 3)cerr << "function redefinition";
		if(code == 4)cerr << "function not found";
		if(code == 5)cerr << "Incompatible types";
		if(code == 6)cerr << "Invalid operands";
		if(code == 7)cerr<<"Redeclaration of variable";
		if(code == 8)cerr<<"Incorrect arguments for function";
		if(code == 9)cerr << "Using variable without declaration";
		if(code == 10)cerr << "subscripted value is neither array nor pointer nor vector";
		if(code == 11)cerr << "Symbol not a member of struct";
		if(code == 12)cerr << "Symbol not a pointer";
		if(code == 13)cerr << "Assignment to array not allowed";
		if(code == 14)cerr << "Indexing into an element which is not an array";
		cerr <<" at line number "<<l_no<<endl;	
		abort();
	}
	void err(int code, string s)
	{
		cerr << "Error: ";
		if(code == 1)cerr << "Undefined reference to "<<s;
		if(code == 2)cerr << "Invalid operand to "<<s; 
		
		cerr <<" at line number "<<l_no<<endl;	
		abort();
	}
	void warning(type *n1, type * n2)
	{
		if(equal(n1, n2))return;
		cerr << "Warning: ";
		cerr << "Assignment from incompatible type "<<n2->name<<" to "<<n1->name;
		
		cerr <<" at line number "<<l_no<<endl;	
	}
}
class symbols
{
	public :
		string name;
		int width;
		type* t;
		int offset;
		bool param;
		symbols(string n, int w, int o, type* t1, bool p)
		{
			name = n;
			width = w;
			offset = o;
			t = t1;
			param = p;
		}
};

class symTab
{
	public:
		vector <symbols*> table;

		void put(string n, int w, int o, type* t, bool p)
		{
			symbols * x = new symbols(n, w, o, t, p);
			table.push_back(x);
		}
		int total_width()
		{
			int sum = 0;
			for(int i = 0; i <table.size(); i++)
				sum+=table[i]->width;
			return sum;
		}
		void print()
		{
			for (int i = 0; i < table.size(); ++i)
			{
				cout<<"\tname: "<<table[i]->name<<" type: "<<(table[i]->t)->name<<" width: "<<table[i]->width<<" offset: "<<table[i]->offset<<" is_param: "<<table[i]->param<<endl;
				cout<<string('-',100)<<endl;
			}
		}
		bool InScope(string s)
		{
			for (int i = 0; i < table.size(); ++i)
			{
				if(table[i]->name==s)
				{
					return true;
				}
			}
			return false;
		}
		type * getType(string s)
		{
			for(int i = 0; i <table.size(); i++)
				if(table[i]->name == s)
					return table[i]->t;
		}
};

class globalSymbol
{
	public :
		int width;
		string name;
		type* t;
		int offset;
		symTab* table;
		vector<type *> params;
		globalSymbol(string n, int w, int o, type* t1, symTab* tab, vector<type*> v)
		{
			name = n;
			width = w;
			offset = o;
			t = t1;
			table = tab;
			params = v;
		}
		globalSymbol(string n, int w, int o, type* t1, symTab* tab)
		{
			name = n;
			width = w;
			offset = o;
			t = t1;
			table = tab;
		}
};

class globalSymTab
{
	public:
		vector <globalSymbol*> table;
		void put(string n, int w, int o, type* t, symTab* tab, vector<type*> v)
		{
			globalSymbol * x = new globalSymbol(n, w, o, t, tab, v);
			table.push_back(x);
		}
		void put(string n, int w, int o, type* t, symTab* tab)
		{
			globalSymbol * x = new globalSymbol(n, w, o, t, tab);
			table.push_back(x);
		}
		
		void printTable()
		{
			cout<<endl;
			for (int i = 0; i < table.size(); ++i)
			{
				cout<<"name: "<<table[i]->name<<" return type: "<<(table[i]->t)->name<<" width: "<<table[i]->width<<" offset: "<<table[i]->offset<<" symbolTable: \n";
				cout << "parameters :";
				for(int j = 0; j <table[i]->params.size(); j++)
				{
					cout << table[i]->params[j]->name << " ";
				}
				cout << endl;
				cout<<string('-',100)<<endl;

				(table[i]->table)->print();
				cout<<string('-',100)<<endl;
			}
		}
		int struct_size(string s)
		{
			for (int i = 0; i < table.size(); ++i)
			{
				if(table[i]->name==s)
					return (table[i]->table)->total_width();
			}
		}
		
		symTab * symbStruct(string n)
		{
			for(int i = 0; i <table.size(); i++)
			{
				if(table[i]->name == n && (table[i]->t)->name == "STRUCT")
					return table[i]->table;
			}
			err(1,n);
			return 0;
		}
		symTab * symbFunc(string n)
		{
			for(int i = 0; i <table.size(); i++)
			{
				if(table[i]->name == n && (table[i]->t)->name != "STRUCT")
					return table[i]->table;
			}
			err(1,n);
			return 0;
		}
		int findFunc(string n, vector <type*> para_type)
		{
			bool b = 0;
			int ret = 0;
			for(int i = 0; i <table.size(); i++)
			{
				if(table[i]->name == n && (table[i])->params.size() == para_type.size())
				{
					b =1;
					ret = 2;
					for(int j = 0; j <para_type.size(); j++)
					{
						if(!equal(para_type[j], (table[i])->params[j]))
						{
								b = 0;
								break;
						}
					}
					if(b)return 1;

				}
			}
			return ret;
		}

		bool findFunc(string n)
		{
			for(int i = 0; i <table.size(); i++)
			{
				if(table[i]->name == n && (table[i]->t)->name != "STRUCT")return 1;
			}
			return 0;
		}
		bool findStruct(string n)
		{
			bool b = 0;
			for(int i = 0; i <table.size(); i++)
			{
				if(table[i]->name == n && (table[i]->t)->name=="STRUCT")
					b = 1;
			}
			return b;
			
		}
		type * findtype(string s)
		{
			for(int i = 0; i <table.size(); i++)
				if(table[i]->name == s)
					return table[i]->t;
			err(1,s);

		}
};

namespace
{

	globalSymTab *top = new globalSymTab();
	symTab *top_local = new symTab();
	string name,name_func;
	type* type1;
	type* old_type;
	type* ret;
	vector <type*> params;
	int old_width, width,offset,val;
	
}

class abstract_astnode
{
	public:
		type *t;
		virtual int print (int ident) = 0;
		// virtual int value () = 0;
		// virtual string generate_code(const symbolTable&) = 0;
		// virtual basic_types getType() = 0;
		// virtual bool checkTypeofAST() = 0;
	// 	protected:
	// 	// virtual void setType(basic_types) = 0;
	// private:
		// typeExp astnode_type;
};

class stmt_astnode : public abstract_astnode
{
	public:
		string stmt_name;
		virtual int print(int ident)=0;
		virtual void validate(type *t){}
};

class exp_astnode : public stmt_astnode
{
	public:
		string exp_name;
		virtual int print(int ident) = 0;
		virtual void validate(){};
};

class unary_astnode : public exp_astnode
{
	private:
		exp_astnode * left;
	public:
		unary_astnode(string s, exp_astnode *l)
		{
			exp_name = s;
			if(s=="*")
			{
				if(l->t == 0 || (l->t)->name!="pointer")
					err(2, "*");
				else
					t = (l->t)->t; 
			}
			else if(s=="&")
			{
				t = new pointer_type(l->t);
			}
			else
			{
				t = l->t;
			}
			left = l;

		}
		virtual int print(int ident)
		{			
			cout<< "("<<exp_name << ' ';
			int x = left->print(ident + exp_name.size()+2);
			cout<<")"; 
			return x+3+exp_name.size();
		}		
};

class binary_astnode : public exp_astnode
{
	private:
		exp_astnode * left, *right;
		int cast;
	public:
		binary_astnode(string s, exp_astnode *l, exp_astnode* r)
		{
			exp_name = s;
			left = l;
			right = r;
			string n1 = (l->t)->name;
			string n2 = (r->t)->name;
			if(s!="AND_OP" && s!="OR_OP" && s!="EQ_OP" || s!="NE_OP")
			{
				if((n1=="int" || n1=="float") && (n2=="int" || n2=="float"))
				{
					if(n1!=n2)
					{
						if(n1=="int")
							cast=1;
						else
							cast=2;
						t = new base_type("float");
					}
					else
					{
						t = l->t;
						cast=0;
					}
				}
				else if(n1 == "int" && (n2 == "pointer" || n2 =="array"))
				{
					t = r->t;
				}
				else if(n2 == "int" && (n1 == "pointer" || n1 =="array"))
				{
					t = l->t;
				}
				else 
				{
					cerr << "Error: invalid operands for "<<s<<" at line number "<<l_no<<endl;
					abort();							//CHECK in future for correctness!!!
				}
			}
			else
				t = new base_type("int");
		}
		virtual int print(int ident)
		{
			cout<< "("<<exp_name;
			//t->print();
			int x=0,y=0;
			if(cast==1)
			{
				cout<<"-FLOAT ( TO-FLOAT ";
				x = left->print(ident+ exp_name.size()+2+11+6);
				cout<<")";
				cout<<' ';
				y = right->print(ident+ exp_name.size()+2+11+x+1+1+6);
				cout<<")"; 
				return x+y+exp_name.size()+4+12+6;
			}
			else if(cast==2)	
			{
				cout<<"-FLOAT ";
				x = left->print(ident+ exp_name.size()+2+6);
				cout<<' ';
				cout<<"( TO-FLOAT ";
				y = right->print(ident+ exp_name.size()+2+11+x+1+6);
				cout<<")";
				cout<<")"; 
				return x+y+exp_name.size()+4+12+6;
			}
			else
			{
				if(t->name=="int")
				{
					cout<<"-INT ";
					x = left->print(ident+ exp_name.size()+2+4);
					cout<<' ';
					y = right->print(ident+ exp_name.size()+2+x+1+4);
					cout<<")"; 
					return x+y+exp_name.size()+4+4;
				}
				else if(t->name=="float")
				{
					cout<<"-FLOAT ";
					x = left->print(ident+ exp_name.size()+2+6);
					cout<<' ';
					y = right->print(ident+ exp_name.size()+2+x+1+6);
					cout<<")"; 
					return x+y+exp_name.size()+4+6;
				}
			}	
		}
};

class float_astnode : public exp_astnode
{
	private:
		float val;
	public:
		float_astnode(float s)
		{
			val = s; 
			t= new base_type("float");
		}
		virtual int print(int ident)
		{
			cout<< "(FloatConst "<<val<<")"; 
			string s = to_string(val);
			return 13 + s.size();
		}
};

class int_astnode : public exp_astnode
{
	private:
		int val;
	public:
		int_astnode(int s)
		{
			val = s; 
			t = new base_type("int");
		}
		virtual int print(int ident)
		{
			cout<< "(IntConst "<<val<<")"; 
			string s = to_string(val);
			return s.size() + 11;
		}
};

class string_astnode : public exp_astnode
{
	private:
		string val;
	public:
		string_astnode(string s)
		{
			val = s;
			t = new base_type("string");
		}
		virtual int print(int ident)
		{
			cout<< "(StringConst "<<val<<")"; 
			return val.size() + 14;
		}
};

class func_astnode : public exp_astnode  					//CHECK in future!!!
{
	private:
		string val; //identifier
		vector<exp_astnode*> list;
	public:
		func_astnode(string s){
			val = s;
		}
		
		func_astnode(string s, vector <exp_astnode*> a){
			val = s;
			list = a;
			t = top->findtype(val);          //add findtype
		}
		virtual int print(int ident)
		{
			int x = 0;
			cout<< "(" <<val <<' ';
			if(!list.empty()){

			int x = 0, y = 0;
			list[0]->print(ident+2+val.size());
			cout<<"\n";
			cout << string(ident+2+val.size(), ' ');
			for(int i = 1; i <list.size(); i++)
			{
				y =list[i]->print(ident+2+val.size());
				x = max(x,y);
				cout<<"\n";
				cout << string(ident+2+val.size(), ' ');
			}
		}
			cout<<")"; 
			return x + val.size() + 3;
		}
		
		void validate()
		{
			vector <type*> vec;
			for(int i = 0; i <list.size(); i++){
				vec.push_back(list[i]->t);
			
			}
			int k = top->findFunc(val, vec);
			if(k == 0)err(1,val);	
			if(k == 2)err(8);
		}
};		

class ass_astnode : public exp_astnode
{
	private:
		exp_astnode * left, *right;
	public:
		ass_astnode(exp_astnode *l, exp_astnode *r)
		{
			exp_name = "Ass";
			left = l;
			right = r;

			string n1 = (l->t)->name;
			string n2 = (r->t)->name;
			if(n1 == "array"){
				err(13);
			}
			else if(n1 == "pointer"){
				
				if(n2 == "int" || n2 == "float" || n2 == "array"|| n2 == "pointer")
					warning(l->t,r->t);
				else
					err(5);
			}
			else if(n1 == "int"){
					
				if(n2 == "int" || n2 == "float" || n2 == "array"|| n2 == "pointer")
					warning(l->t,r->t);
				else
					err(5);
			}
			else if(n1 == "float"){
					
				if(n2 == "int" || n2 == "float")
					warning(l->t,r->t);
				else
					err(5);
			}
			else if(n1 != n2)err(5);

			t = l->t;
		}
		virtual int print(int ident)
		{
			cout<< "("<<exp_name << ' ';
			int x = left->print(ident+2+exp_name.size());
			cout<<' ';
			int y = right->print(ident + 3 + exp_name.size()+ x);
			cout<<")"; 
			return exp_name.size()+x+y+4;
		}
};

class if_astnode : public stmt_astnode
{
	private:
		exp_astnode * left;
		stmt_astnode *middle, *right;
	public:
		if_astnode(exp_astnode *l, stmt_astnode * m, stmt_astnode *r)
		{
			stmt_name = "If";
			left = l;
			right = r;
			middle = m;
		}
		virtual int print(int ident)
		{
			cout<< "("<<stmt_name << ' ';
			int x = left->print(ident + 2 + stmt_name.size());
			cout<<"\n";
			cout<<string(ident + 4, ' ');
			int y = middle->print(ident + 4);
			cout<<"\n";
			cout<<string(ident + 4, ' ');
			int z = right->print(ident + 4);
			cout<<")"; 
			return max(max(y,z), x + 4);
		}
};

class empty_astnode : public stmt_astnode
{
	public:
		empty_astnode(){stmt_name = "Empty";}

		virtual int print(int ident)
		{
			cout<< "("<<stmt_name<<")";
			return 2+ stmt_name.size(); 
		}
};


class return_astnode : public stmt_astnode
{
	private:
		exp_astnode * left;
	public:
		return_astnode(exp_astnode *l)
		{
			stmt_name = "Return";
			left = l;
		}

		virtual int print(int ident)
		{
			cout<< "("<<stmt_name << ' ';
			int x = left->print(ident + 2 + stmt_name.size());
			cout<<")"; 
			return x  + stmt_name.size() + 3;
		}
		void validate(type * ret)
		{
			if(!equal(ret, left->t))err(5);
		}
};		

class for_astnode : public stmt_astnode
{
	private:
		exp_astnode * left, *middle, *right;
		stmt_astnode *stmt;
	public:
		for_astnode(exp_astnode *l, exp_astnode *m, exp_astnode *r, stmt_astnode *s)
		{
			stmt_name = "For";
			left = l;
			middle = m;
			right = r;
			stmt = s;
		}

		virtual int print(int ident)
		{
			cout<< "("<<stmt_name <<' ';
			int x = left->print(ident+5);
			cout<<"\n";
			cout<<string(ident + 5, ' ');
			int y = middle->print(ident + 5);
			cout<<"\n";
			cout<<string(ident + 5, ' ');
			int z = right->print(ident + 5);
			cout<<"\n";
			cout<<string(ident + 5, ' ');
			int w = stmt->print(ident + 5);
			cout<<")"; 
			return max(5+x, max(y,max(z,w+1)));
		}
};

class while_astnode : public stmt_astnode
{
	private:
		exp_astnode * left;
		stmt_astnode * stmt;
	public:
		while_astnode(exp_astnode *l, stmt_astnode *s)
		{
			stmt_name = "While";
			left = l;
			stmt = s;
		}

		virtual int print(int ident)
		{
			cout<< "("<<stmt_name << ' ';
			int x = left->print(ident+7);
			cout<<"\n";
			cout<<string(ident + 7, ' ');
			int y = stmt->print(ident + 7);
			cout<<")";
			return max(7+x, y+1); 
		}	
};

class list_astnode : public stmt_astnode
{
	private:
		stmt_astnode * stmt;
		stmt_astnode * list;
	public:
		list_astnode(stmt_astnode *s)
		{
			stmt = s;
			list = 0;
		}
		list_astnode(stmt_astnode *s, stmt_astnode *l)
		{
			stmt = s;
			list = l;
		}
		virtual int print(int ident)
		{
			int x = 0, y= 0;
			if(list != 0){
				x = list->print(ident);
				cout<<"\n";
				cout<<string(ident, ' ');
				y = stmt->print(ident);
			}
			else {
			y = stmt->print(ident);}
			return max(x, y);
			
		}
};

class block_astnode : public stmt_astnode
{
	private:
		stmt_astnode *block;
	public:
		block_astnode(stmt_astnode *l)
		{
			stmt_name = "Block";
			block = l;
		}

		virtual int print(int ident)
		{
			cout<< "(Block [";
			int x = block->print(ident + 8);
			cout<<"])";
			return 10 + x;
		}	
};

class ref_astnode : public exp_astnode
{
	public:
		string ref_name;
		virtual int print(int ident)=0;
};
/*
class assgn_astnode : public stmt_astnode
{
	private:
		ref_astnode *left;
		exp_astnode *right;
	public:
		assgn_astnode()
		{
			stmt_name = "Ass";
			left = 0;
			right = 0;
		}
		assgn_astnode(ref_astnode *l, exp_astnode *r)
		{
			stmt_name = "Ass";
			left = l;
			right = r;
		}

		virtual int print(int ident)
		{
			int x = 0, y = 0;
			cout<< "("<<stmt_name << ' ';
			if(left!=0)x = left->print(ident + stmt_name.size()+2);
			cout << ' ';
			if(right!=0)y = right->print(ident+ x+ 3 + stmt_name.size());
			cout<<")"; 
			return stmt_name.size() + 4 + x + y;
		}	
};
*/
class id_astnode : public ref_astnode
{
	public:
		string id_name;
		id_astnode(string name)
		{
			ref_name = "Id";
			id_name = name;
			if(top_local->InScope(name)==0)
			{
				err(9);
			}
			for (int i = 0; i < (top_local->table).size(); ++i)
			{
				if((top_local->table[i])->name==id_name)
					t = (top_local->table[i])->t;
			}
		}

		virtual int print(int ident)
		{
			cout<< "("<<ref_name<<" \"" <<id_name<<"\")" ;
			return 5+ref_name.size()+id_name.size();
		}
};

class member_astnode : public ref_astnode
{
	private:
		exp_astnode *id;
		id_astnode *mem;
	public:
		member_astnode(exp_astnode *a,id_astnode *b)
		{
			id=a;
			mem=b;
			symTab* s = top->symbStruct((id->t)->name);
			if(!s->InScope(mem->id_name))err(11);
			t = s->getType(mem->id_name);
		}

		virtual int print(int ident)
		{
			cout<< "(Member ";
			int x = id->print(ident);
			cout<<" ";
			int y = mem->print(ident);
			cout<<")";
			return 5+x+y+5;
		}
};

class arrow_astnode : public ref_astnode
{
	private:
		exp_astnode *id;
		id_astnode *mem;
	public:
		arrow_astnode(exp_astnode *a,id_astnode *b)
		{
			id=a;
			mem=b;
			if((id->t)->name != "pointer")err(12); //Not a pointer
			if((id->t)->t == 0)err(12);
			symTab* s = top->symbStruct(((id->t)->t)->name);
			if(!s->InScope(mem->id_name))err(11);
			t = s->getType(mem->id_name);
		}

		virtual int print(int ident)
		{
			cout<< "(Arrow ";
			int x = id->print(ident);
			cout<<" ";
			int y = mem->print(ident);
			cout<<")";
			return 6+x+y+3;
		}
};

class arrref_astnode : public ref_astnode
{
	private:
		exp_astnode *id;
		exp_astnode *params;
	public:
		arrref_astnode(exp_astnode *a,exp_astnode * b)
		{
			id=a;
			params = b;
			if((id->t)->name != "array")err(14);
			t = (id->t)->t;
			if(t == 0)err(10);
		}

		virtual int print(int ident)
		{
			cout<< "(Arrayref";
			int x = id->print(ident+1);
			cout<<"[";
			int y = params->print(ident+2+x);
			cout<<"])";
			return 4+x+y+8;
		}
};		

class ptr_astnode : public exp_astnode
{
	private:
		ref_astnode *id;
	public:
		ptr_astnode(ref_astnode *a)
		{
			id=a;
			t = new pointer_type(a->t);
		}

		virtual int print(int ident)
		{
			cout<< "(Pointer ";
			int x = id->print(ident);
			cout<<")";
			return x+4+6;
		}
};

class deref_astnode : public ref_astnode
{
	private:
		ref_astnode *id;
	public:
		deref_astnode(ref_astnode *a)
		{
			id=a;
			t = (a->t)->t;
		}

		virtual int print(int ident)
		{
			cout<< "(Deref ";
			int x = id->print(ident);
			cout<<")";
			return 4 + x + 4;
		}
};
