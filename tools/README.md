## `donutGenerator`

Originally created by [@IOKG04](https://github.com/IOKG04) in C. Transpiled into Python for ease of use.

`donutGenerator` is a tool for creating a donut template made from periods to shape your code after.

#### Contents:
* [How to Use](#running-donutgenerator)
* [Drawing donut with minimum amount of characters](#drawing-a-donut-with-minimum-amount-of-characters)
* [Drawing donut with specified inner/outer radius](#drawing-donut-with-specific-outer-and-inner-radius)
* [Errors](#donutgenerator-errors)

### Running `donutGenerator`

`donutGenerator` is a Python script. Run it with `python3 tools/donutGenerator.py` with arguments as shown below.

### Using `donutGenerator`

Please note that the radius will be halfed vertically when drawing the donut so it looks round then viewed with a 1:2 (close to standard) font.

#### Drawing a donut with minimum amount of characters

To make `donutGenerator` generate a donut with a minimum amount of characters, provide that minimum as the first and only argument:
```bash
python3 tools/donut_generator.py [character minimum]
```

Its output will consist of a calculated outer and inner radius, the donut itself and the character amount in the donut.  

##### Example:
```
> python3 tools/donutGenerator.py 300
Outer radius:                   16
Inner radius:                   5

                                
         ...............        
      .....................     
    .........................   
   ...........................  
  ............................. 
 .............     .............
 ...........         ...........
 ...........         ...........
 ...........         ...........
 .............     .............
  ............................. 
   ...........................  
    .........................   
      .....................     
         ...............        

Character count: 352
```

Please note that the output of `donut_generator` will never generate less than the minimum character amount, but might generate more characters, which can be advantageous in case more characters are required due to the geometry of the donut or if you want to include comments.

#### Drawing donut with specific outer and inner radius

To make `donut_generator` generate a donut with a specific outer and inner radius, provide those radii as arguments:
```bash
python3 tools/donut_generator.py [outer radius] [inner radius]
```

Its output will consist of the donut and the amount of characters it contains.  

##### Example:

```
> python3 tools/donutGenerator.py 15 6
          ...........         
       .................      
    .......................   
   .........................  
  ........................... 
 ..........         ..........
 .........           .........
 .........           .........
 .........           .........
 ..........         ..........
  ........................... 
   .........................  
    .......................   
       .................      
          ...........         

Character count: 300
```

### `donutGenerator` errors

#### Error 0: Not enough or too many arguments

You provided either too few (less than 1) or too many (more than 2) arguments.

#### Undocumented errors

If `donutGenerator` doesnt work or works in unexpected ways and shows no error message, please create an issue explaining how the program behaved and what input you provided when you caused that behavior.