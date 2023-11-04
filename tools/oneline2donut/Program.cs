using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;

/*
w = working on
r = reworking
c = coded / testing
x = tested / done

[x] Parse
 [x] Convert to primitives
 [x] Detect strings
  [x] Make escaping characters possible
 [x] Merge primitives into tokens
[x] Donutify input
 [x] Generate donut template
 [x] Map input onto template without splitting groups
[ ] Add arguments
 [ ] Configurations
  [ ] Modular group and formular system
  [ ] (Usable) configuration file format
 [x] Output file (_o)
 [x] More Logs (_l)
 [ ] Even more logs (_l!)
 [x] Disable standard output (_s)
 [x] Disable questions (_y)
 [x] Help message (_h)
 [x] Skip lines (dont map code onto first n lines of donut to leave space for stuff) (_k)
 [x] Print donut size information (_i)
 [x] Specify specific donut size (_d)
[ ] Add error messages where applicable

Errors marked with `(I)` are internal. Please open an issue and describe what exactly you did to cause the error.
*/

namespace oneline2donut;

public static class Config{
    // help message printed on error 4 or when _h flag is given
    public static string helpMessage = """
	The "donutifier" automatically maps code onto a donut.

	Usage:
	 dotnet run [file_in] [options]				Donutifies [file_in] and prints it to the screen. This behavior may be altered by [options].
	
	Options:
	 _o _out _output [file_out]				Saves the generated donut to [file_out].
	 _s _silent						The generated donut isnt printed to the screen.
	 _l _loud						Prints extra/debug information.
	 _i _di _info _donutinfo				Appends dimensions of the generated donut to the donut.
	 _d _dimensions [outer_radius] [inner_radius]		Sets the dimensions of the donut. Exits if specified dimensions are too small.
	 _k _skip _kl _skiplines [n]				Doesnt map code onto the first [n] lines of the generated donut.
	 _y _yes _!						Automatically answered Yes to any questions.
	 _h _help						Prints a help message, then exits.
	
	All options start with _ instead of - as to not run into problems with dotnet.
	If a flag is used multiple times, only the first instance will effect the result.
	""";

    // all strings which match a specific primitive group
    // has to be in same order as PrimitiveGroup enum and in order of first to be checked to last
    // if nothing matches TokenGroup.Other is given
    public static string[][] primitiveGroupMatches = new string[][]{
	new string[] {" ", "\t", "\n"},
	new string[] {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"},
	new string[] {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"},
	new string[] {"."},
	new string[] {";", ","},
	new string[] {"(", ")", "[", "]", "{", "}"},
	new string[] {"\"\"\"", "'''", "\"", "'", "`"},
	new string[] {"\\"},
	new string[] {"_"},
    };
    // all combinations of Tokens that can combine into another content
    // has to be ordered so that special cases come before general ones
    // before this is used, strings have to be found and made into seperate tokens
    public static (TokenGroup[] formular, TokenGroup result)[] tokenGroupFormulars = new (TokenGroup[] formular, TokenGroup result)[]{
	// words
	(new TokenGroup[] {TokenGroup.word, TokenGroup.letter}, TokenGroup.word),		// words can be extended by letters
	(new TokenGroup[] {TokenGroup.word, TokenGroup.digit}, TokenGroup.word),		// words can be extended by digits
	(new TokenGroup[] {TokenGroup.word, TokenGroup.underscore}, TokenGroup.word),		// words can be extended by underscores
	(new TokenGroup[] {TokenGroup.letter}, TokenGroup.word),				// letters are words
	(new TokenGroup[] {TokenGroup.underscore}, TokenGroup.word),				// underscores are words
	// numbers
	(new TokenGroup[] {TokenGroup.number, TokenGroup.digit}, TokenGroup.number),		// numbers can be extended by digits
	(new TokenGroup[] {TokenGroup.number, TokenGroup.period}, TokenGroup.number),		// numbers can be extended by periods
	(new TokenGroup[] {TokenGroup.number, TokenGroup.underscore}, TokenGroup.number),	// numbers can be extended by underscores
	(new TokenGroup[] {TokenGroup.digit}, TokenGroup.number),				// digits are numbers
	// assume unsplittable others
	(new TokenGroup[] {TokenGroup.other, TokenGroup.other}, TokenGroup.other),		// others can be extended by others
    };

    public static int donutIR, donutOR, donutCC, minLine;
    public static bool printDonut, printDebug, printDonutInfo, specificDonutDimensions;
}

public class Program{
    public static List<Token>	tokens;
    public static int		totalCharCount;
    public static string[]	donutTemplate;
    public static string	outp;

    public static string?	outpFile;

    public static int Main(string[] args){
	// error on not enough arguments
	if(args.Length < 1){
	    Console.WriteLine("Error 4: Not enough arguments\n");
	    Console.WriteLine(Config.helpMessage);
	    throw new Exception("Error 4: Not enough arguments");
	}
	// help message
	if(Array.IndexOf(args, "_h") != -1 || Array.IndexOf(args, "_help") != -1){
	    Console.WriteLine(Config.helpMessage);
	    return 0;
	}
	// error on nonexistent input file
	if(!File.Exists(args[0])){
	    Console.WriteLine("Error 5: Input file doesnt exist");
	    throw new Exception("Error 5: Input file doesnt exist");
	}

	// interpret flags and exit if exit is requested
	int f = InterpretFlags(args);
	if(f != 0) return f;
	if(Config.printDebug) Console.WriteLine("Finished interpreting flags\nStarting loading file");

	// read baseCode
	string baseCode = File.ReadAllText(args[0]);
	if(Config.printDebug) Console.WriteLine("Finished loading file\nStarting filtering file");
	
	// filter baseCode
	baseCode = baseCode.Replace("\n", " ");
	baseCode = baseCode.Replace("\t", " ");
	while(baseCode.Contains("  ")) baseCode = baseCode.Replace("  ", " ");
	while(baseCode.EndsWith(' ')) baseCode = baseCode.Remove(baseCode.Length - 1);
	totalCharCount = baseCode.Length;
	if(Config.printDebug) Console.WriteLine("Finished filtering file\nStarting finding primitives");

	// parse baseCode
	tokens = Token.FindPrimitives(baseCode);
	if(Config.printDebug) Console.WriteLine("Finished finding primitives: " + tokens.Count + "\nStarting parsing strings");
	Token.ParseStrings(ref tokens);
	if(Config.printDebug) Console.WriteLine("Finished parsing strings\nStarting applying formulars");
	Token.ApplyFormulars(ref tokens);
	if(Config.printDebug) Console.WriteLine("Finished applying formulars: " + tokens.Count);

	// get donut template
_generate_donut:
	if(Config.printDebug) Console.WriteLine("Starting generating donut with " + totalCharCount + " chars");
	donutTemplate = GenerateDonut();
	// throw error on nonexistent donutTemplate
	if(donutTemplate.Length < 1){
	    Console.WriteLine("Error 3 (I): donutTemplate nonexistent");
	    throw new Exception("Error 3 (I): donutTemplate nonexistent");
	}
	if(Config.printDebug) Console.WriteLine("Finished generating donut\nStarting mapping onto donut");

	// map tokens onto donut
	int currentChar = 0, currentRow = 0, currentToken = 0, startToken, dotsLeft;
	outp = "";
	while(currentToken < tokens.Count){
	    // skip lines
	    if(currentRow < Config.minLine){
		outp += donutTemplate[currentRow];
		outp += '\n';
		currentRow++;
		continue;
	    }
	    // test if linebreak is needed
	    if(currentChar >= donutTemplate[currentRow].Length){
		currentRow++;
		currentChar = 0;
		outp += '\n';
		// retry with bigger donut on donutTemplate being too small
		if(currentRow >= donutTemplate.Length){
		    // error on specific dimensions too small
		    if(Config.specificDonutDimensions){
		    	Console.WriteLine("Error 9: Specified donut dimensions are too small");
		    	throw new Exception("Error 9: Specified donut dimensions are too small");
		    }
		    // increase totalCharCount by amount of unmapped characters (+ 1 to make bugs less likely)
		    int unmappedCharacterAmount = 1;
		    for(int i = currentToken; i < tokens.Count; i++) unmappedCharacterAmount += tokens[i].content.Length;
		    totalCharCount += unmappedCharacterAmount;
		    if(Config.printDebug) Console.WriteLine("Generated donut was too small for mapping, restarting");
		    goto _generate_donut;
		}
	    }

	    // print if currentChar is not '.'
	    if(donutTemplate[currentRow][currentChar] != '.'){
		outp += donutTemplate[currentRow][currentChar];
		currentChar++;
		continue;
	    }

	    //get fitable tokens
	    dotsLeft = CountContinuousDots(donutTemplate[currentRow], currentChar);
	    startToken = currentToken;
	    int tokensLength = 0;
	    while(tokensLength <= dotsLeft && currentToken < tokens.Count){
		tokensLength += tokens[currentToken].content.Length;
		currentToken++;
	    }
	    if(currentToken > startToken + 1){
		currentToken--;
		tokensLength -= tokens[currentToken].content.Length;
	    }

	    // get extra spaces and spacesLeft/tokensLength
	    int spacesLeft = dotsLeft - tokensLength;
	    double sL_tL = spacesLeft / (double)(currentToken - 1 > startToken ? tokensLength - tokens[currentToken - 1].content.Length : tokensLength); // explicit double division, i hate it
	    double currentSpacesAmount = 0;
	    
	    // print tokens with spaces
	    for(int i = startToken; i < currentToken; i++){
		currentChar += tokens[i].content.Length;
		outp += tokens[i].content;
		currentSpacesAmount += sL_tL * tokens[i].content.Length;
		while(currentSpacesAmount >= 0.95 && i < currentToken - 1){
		    currentChar++;
		    outp += ' ';
		    currentSpacesAmount--;
		}
	    }
	    if(currentChar < donutTemplate[currentRow].Length && donutTemplate[currentRow][currentChar] == '.') currentChar += CountContinuousDots(donutTemplate[currentRow], currentChar);
	}
	// print rest of donut
	while(currentRow < donutTemplate.Length){
	    outp += donutTemplate[currentRow][currentChar];
	    currentChar++;
	    if(currentChar >= donutTemplate[currentRow].Length){
		currentRow++;
		currentChar = 0;
		outp += '\n';
	    }
	}
	if(Config.printDebug) Console.WriteLine("Finished mapping onto donut\nStarting I/O processes");

	// print donut info
	if(Config.printDonutInfo) outp += "\nInner radius: " + Config.donutIR + "\tOuter radius: " + Config.donutOR + "\tCharacter count: " + Config.donutCC;

	// output donut
	if(Config.printDonut) Console.WriteLine(outp);
	if(outpFile != null) File.WriteAllText(outpFile, outp);
	if(Config.printDebug) Console.WriteLine("Finished I/O processes");

	return 0;
    }
    private static string[] GenerateDonut(){
	int c;
	float a = 0;
	string[] outp;

	do{
	    // draw donut
	    c = 0;
		int outsideR, insideR;
		if(Config.specificDonutDimensions){
		    outsideR = Config.donutOR;
		    insideR = Config.donutIR;
		}
		else{
		    outsideR = (int)(Math.Sqrt((2 * totalCharCount) / (0.8775 * Math.PI) + a)) + 1;
		    insideR  = (int)(outsideR * 0.35);
		}
		int center  = outsideR,
		centery = outsideR / 2;
	    outp = new string[outsideR];
	    for(int y = 0; y < outsideR; y++){
		outp[y] = "";
		for(int x = 0; x < outsideR * 2 + 1; x++){
		    if(x != outsideR * 2 && Math.Sqrt((x - center) * (x - center) + (y - centery) * (y - centery) * 4) < outsideR && Math.Sqrt((x - center) * (x - center) + (y - centery) * (y - centery) * 4) >= insideR) outp[y] += '.';
		    else outp[y] += ' ';
		    c++;
		}
	    }
	    a += 0.5f; // increase additional size in case generated donut has less characters than totalCharCount

	    // update config information
	    Config.donutOR = outsideR;
	    Config.donutIR = insideR;
	    Config.donutCC = c;
	} while(c < totalCharCount); // make sure enough characters exist


	return outp;
    }
    private static int CountContinuousDots(string str, int startIndex){
	int c = 0;
	for(int i = startIndex; i < str.Length; i++){
	    if(str[i] == '.') c++;
	    else if(c != 0) return c;
	}
	return c;
    }
    private static int InterpretFlags(string[] args){
	int flagIndex;
	outpFile = null;
	Config.printDonut = true;
	Config.printDebug = false;
	Config.printDonutInfo = false;
	Config.specificDonutDimensions = false;
	Config.minLine = 0;
	bool autoYes = false;

	// `_y` flag
	if(Array.IndexOf(args, "_y") != -1 || Array.IndexOf(args, "_yes") != -1 || Array.IndexOf(args, "_!") != -1) autoYes = true;

	// `_o [file]` flag
	if((flagIndex = Array.IndexOf(args, "_o")) != -1 || (flagIndex = Array.IndexOf(args, "_out")) != -1 || (flagIndex = Array.IndexOf(args, "_output")) != -1){
	    // error on nonexistent [file]
	    if(args.Length <= flagIndex + 1){
	        Console.WriteLine("Error 6: No file after _o flag");
	        throw new Exception("Error 6: No file after _o flag");
	    }
	    // test if [file] exists
	    if(!autoYes && File.Exists(args[flagIndex + 1])){
	        Console.WriteLine(args[flagIndex + 1] + " already exists\nOverwrite? Y/n");
	        string inp = Console.ReadLine().ToLower();
	        if(inp == "n" || inp == "no" || inp == "0"){
	    	Console.WriteLine("Exit 1: Output file exists and should not be overwritten");
	    	return 1;
	        }
	    }
	    outpFile = args[flagIndex + 1];
	}

	// `_s` flag
	if(Array.IndexOf(args, "_s") != -1 || Array.IndexOf(args, "_silent") != -1){
	    Config.printDonut = false;
	    if(!autoYes && outpFile == null){
		Console.WriteLine("No output will be generated.\nAre you sure you want to keep all output disabled? y/N");
		string inp = Console.ReadLine().ToLower();
		if(!(inp == "y" || inp == "yes" || inp == "1")) Config.printDonut = true;
	    }
	}

	// `_l` flag
	if(Array.IndexOf(args, "_l") != -1 || Array.IndexOf(args, "_loud") != -1) Config.printDebug = true;

	// `_i` flag
	if(Array.IndexOf(args, "_i") != -1 || Array.IndexOf(args, "_info") != -1 || Array.IndexOf(args, "_di") != -1 || Array.IndexOf(args, "_donutinfo") != -1) Config.printDonutInfo = true;

	// `_d` flag
	if((flagIndex = Array.IndexOf(args, "_d")) != -1 || (flagIndex = Array.IndexOf(args, "_dimensions")) != -1){
	    // error on too few arguments
	    if(args.Length <= flagIndex + 2){
	    	Console.WriteLine("Error 7: No dimensions after _d flag");
	    	throw new Exception("Error 7: No dimensions after _d flag");
	    }
	    Config.specificDonutDimensions = true;
	    Config.donutOR = int.Parse(args[flagIndex + 1]);
	    Config.donutIR = int.Parse(args[flagIndex + 2]);
	    // error on nonexistent radii
	    if(Config.donutOR < 1 || Config.donutIR < 0){
	    	Console.WriteLine("Error 8: Radii too small");
	    	throw new Exception("Error 8: Radii too small");
	    }
	}

	// `_k` flag
	if((flagIndex = Array.IndexOf(args, "_k")) != -1 || (flagIndex = Array.IndexOf(args, "_skip")) != -1 || (flagIndex = Array.IndexOf(args, "_kl")) != -1 || (flagIndex = Array.IndexOf(args, "_skiplines")) != -1){
	    // error on too few arguments
	    if(args.Length <= flagIndex + 1){
		Console.WriteLine("Error 10: No value after _k flag");
		throw new Exception("Error 10: No value after _k flag");
	    }
	    Config.minLine = int.Parse(args[flagIndex + 1]);
	    // error on negative minLine
	    if(Config.minLine < 0){
		Console.WriteLine("Error 11: Negative minimum lines");
		throw new Exception("Error 11: Negative minimum lines");
	    }
	}

	return 0;
    }
}

// tokens are combinations of Primitives that have a specific function in a programming language, like a function name, a discriminator, etc.
public struct Token{
    public TokenGroup	tokenGroup;
    public string	content;
    public string ToString(bool showGroup = false){
	string outp = showGroup ? "{ \"group\": \"" + tokenGroup.ToString() + "\", \"content\": \"" + content + "\" }" : content;
	return outp;
    }
    public Token(TokenGroup _tokenGroup, string _content){
	tokenGroup = _tokenGroup;
	content = _content;
    }

    // finds first Primitive in str and removes is from str
    public static Token FindFirstPrimitive(ref string str){
	// setup parameters for no matches
	TokenGroup pg = TokenGroup.other;
	string c = str[0].ToString();;

	// find matching PrimitiveGroup
	for(int i = 0; i < Config.primitiveGroupMatches.Length; i++){
	    for(int j = 0; j < Config.primitiveGroupMatches[i].Length; j++){
		// if matches, set parameters and return
		if(str.StartsWith(Config.primitiveGroupMatches[i][j])){
		    pg = (TokenGroup)i;
		    c = Config.primitiveGroupMatches[i][j];
		    goto _find_first_primitive_return;
		}
	    }
	}

_find_first_primitive_return:
	// remove first Primitive from string and return
	str = str.Remove(0, c.Length);
	return new Token(pg, c);
    }
    // finds and returns a list of all Primitives in str
    public static List<Token> FindPrimitives(string str){
	List<Token> outp = new List<Token>();
	while(str.Length > 0) outp.Add(FindFirstPrimitive(ref str));
	return outp;
    }

    // parses all strings in tokens and switches them with a string_ token
    // returns amount of strings found
    public static int ParseStrings(ref List<Token> tokens){
	int stringsFound = 0;
	while(tokens.Any(t => t.tokenGroup == TokenGroup.stringStarters)){
	    int starti = tokens.FindIndex(t => t.tokenGroup == TokenGroup.stringStarters);
	    Token startt = tokens[starti];
	    int endi = starti;
	    do{
		endi = tokens.FindIndex(endi + 1, t => t.tokenGroup == TokenGroup.stringStarters && t.content == startt.content);
	    }while(IsEscaped(tokens, endi));
	    stringsFound++;
	    string c = "";
	    for(int i = starti; i <= endi; i++) c += tokens[i].content;
	    Token str = new Token(TokenGroup.string_, c);
	    tokens.RemoveRange(starti, endi - starti + 1);
	    tokens.Insert(starti, str);
	}
	return stringsFound;
    }
    private static bool IsEscaped(List<Token> tokens, int i){
	bool outp = false;
	while(--i > 0 && tokens[i].tokenGroup == TokenGroup.escape) outp = !outp;
	return outp;
    }
    public static int ApplyFormulars(ref List<Token> tokens){
	int formularsApplied = 0;
	(int index, int formular) firstFoundFormular = FindFirstFormularIndex(tokens);
	while(firstFoundFormular.index != -1){
	    string c = "";
	    for(int i = 0; i < Config.tokenGroupFormulars[firstFoundFormular.formular].formular.Length; i++) c += tokens[i + firstFoundFormular.index].content;
	    Token newToken = new Token(Config.tokenGroupFormulars[firstFoundFormular.formular].result, c);
	    tokens.RemoveRange(firstFoundFormular.index, Config.tokenGroupFormulars[firstFoundFormular.formular].formular.Length);
	    tokens.Insert(firstFoundFormular.index, newToken);
	    firstFoundFormular = FindFirstFormularIndex(tokens);
	}
	return formularsApplied;
    }
    private static (int index, int formular) FindFirstFormularIndex(List<Token> tokens){
	for(int i = 0; i < tokens.Count; i++){
	    for(int j = 0; j < Config.tokenGroupFormulars.Length; j++){
		if(i + Config.tokenGroupFormulars[j].formular.Length >= tokens.Count) continue;
		bool isMatch = true;
		for(int k = 0; k < Config.tokenGroupFormulars[j].formular.Length; k++){
		    if(tokens[i + k].tokenGroup != Config.tokenGroupFormulars[j].formular[k]){ isMatch = false; break; }
		}
		if(isMatch) return (i, j);
	    }
	}
	return (-1, -1);
    }
}
// list of all groups a Token can be a part of
// groups with a value below 128 are considered primitive
public enum TokenGroup : byte{
    space		= 0,   // " ", "\t", "\n"
    letter		= 1,   // alphabetic characters
    digit		= 2,   // numeric characters
    period		= 3,   // "."
    discriminator	= 4,   // ";", ","
    brackets		= 5,   // normal, square and curly brackets
    stringStarters	= 6,   // "'''", "\"", "'", other common string starters
    escape		= 7,   // "\\", other common escape characters
    underscore		= 8,   // "_"
    string_		= 128, // strings seperated by stringStarters				(stringStarters + [whatever]? + stringStarters)
			       // (with underscore at end so it isnt the same as the keyword)
    number		= 129, // integer or floating point number				(digits + period? + digits? | underscore)
    word		= 130, // keyword or variable/function name				(letters + digits? + underscore?)
    other		= 255, // characters not assigned to another group
}
