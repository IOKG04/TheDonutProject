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

<!--
TODO: ADD IN MORE DOCUMENTATION AND AN ACTUAL SPECIFICATION
-->

### Limitations

The default configuration coded into the "donutifier" is made for c like programming languages, and probably wont work on other kinds of programming languages.  
I ([@IOKG04](https://github.com/IOKG04)) will try to make the "donutifier" work with more languages using specific configurations.  
If you want to change the default configuration to work with your programming language, feel free to change the code for your needs. The configuration relavant lines are 185-195, 229-243 and 298-313. I tried explaining as much as possible with comments, and you can open issue (on [my fork](https://github.com/IOKG04/TheDonutProject)).

Any comments in the provided code will break the result at the moment, as there is no feature implemented to remove them.
