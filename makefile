all:    Scanner.ih Scanner.h Scannerbase.h lex.cc parse.cc main.cc Parser.h Parserbase.h Parser.ih
	g++   --std=c++0x lex.cc parse.cc main.cc -o parser
	./parser < test.c > junk

        
Scanner.ih: lex.l
	if [ ! -e Scanner.ih ]; then \
		flexc++ lex.l;\
                sed -i '/include/a #include "Parserbase.h"' Scanner.ih; \
	fi

parse.cc Parser.h Parserbase.h Parser.ih: parse.y
	bisonc++  --construction parse.y; 
	sed -i '/insert preincludes/a #include "class.cpp"' Parserbase.h;
	sed -i '\|STYPE__     d_val__;| d' Parserbase.h;
	sed -i '\|typedef Meta__::SType STYPE__;| a \\tpublic: static STYPE__  d_val__; ' Parserbase.h;
	# sed -i '/include "Parser.ih"/a #include "class.cpp"' parse.cc;
	sed -i '\|void Parser::print__()| i Meta__::SType ParserBase::d_val__; ' parse.cc


.PHONY: clean     
clean:
	$(RM) -f Parser.ih Parser.h Parserbase.h parse.cc Scanner.ih Scanner.h Scannerbase.h lex.cc parse.y.output parser junk *~

