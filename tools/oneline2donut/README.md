## The "donutifier"

### Running the donutifier

To run the "donutifier", first make sure you have the [.NET 7.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) installed, then run
```bash
dotnet run [path to file file]
```
while in the prgrams directory to "donutify" `[path to file file]`.

### Using the "donutifier"

When providing one argument, the "donutifier" will generate a donut and map the contents of the provided file onto it.  
The result is printed to standard output.

Please note that removing any unecessary linebreaks, spaces and tabs will greatly improve the result, though it will still not be perfect.

### Configurations

Configuration files can be used to change the behavior of the "donutifier" so it works with not c like programming languages.

#### Sections

A "donutifier" configuration file is is comprised of multiple sections, each having an effect on one part of the "donutifying" process:
* Primitive group matches
* Token formulars
* Other configurations

##### Primitive group matches

Primitives are single characters or small strings which can be grouped into a general catigories called primitive groups, like *letter*, *digit* or *underscore*.  
A primitive group can have only one specific sequence of characters be part of it (like with the *underscore* primitive group), or it can have multiple possible values (like with the *letter* and *digit* primitive groups).  
Since primitive groups are referred to in the "donutifier's" internal logic as bytes and since a couple of the 256 values are used for other things too (like the *others* primitive group), only a certain number of primitive groups can exist. Most configurations however shouldnt get close to those limitations, as around 127 possible peimitive groups are still usable.

Primitive group matches define which characters or character sequences should belong to a specific primitive group.  
The "donutifier" tests if the provided code's start matches a primitive group and then removing the matching part by going from lowest index/primitive group to highest index/primitive group and from first primitive group match to last primitive group match.  
If no primitive groups matches match the start of the provided code, the first character is assigned the *other* primitive group (255).  
This means that if you want to be have character sequences as primitive group matches, they should come in a lower primitive group or in an earlier position in the same primitive group match than any primitive group match starting with the same character(s).

In the configuration file primitive group matches are defined by putting all matching characters or character sequences on one line, seperated by spaces.  
If you want to include space (` `) as a primitive group match, replace it with `\s`.

##### Token formulars

Token formulars are used by the "donutifier" to combine primitives into longer, more complex tokens.  
They contain a list of token groups (a superset of primitive groups), the match, and a token group as the result.  
If the match is found in the list of primitives/tokens generated before (both by this step and by the primitive matching step), the tokens in the match will be combined into a new token with the result as the new token group.  
More specifically the primitive/token list is checked from first to last primitive/token and from first formular to last, meaning more specific formulars should come before more general ones.

In the configuration file formulars are defined by putting the token group(s) of the match and the resulting token group seperated by spaces.  
As there is always just one result, the result doesnt need to be seperated in a different way.

##### Other configurations

<!--
TODO: Add this section and some examples (and the actual code to implement this of course)
-->

### Limitations

The default configuration coded into the "donutifier" is made for c like programming languages, and probably wont work on other kinds of programming languages.  
I ([@IOKG04](https://github.com/IOKG04)) will try to make the "donutifier" work with more languages using specific configurations.  
If you want to change the default configuration to work with your programming language, feel free to change the code for your needs. The configuration relavant lines are 185-195, 229-243 and 298-313. I tried explaining as much as possible with comments, and you can open issue (on [my fork](https://github.com/IOKG04/TheDonutProject)).

Any comments in the provided code will break the result at the moment, as there is no feature implemented to remove them.
