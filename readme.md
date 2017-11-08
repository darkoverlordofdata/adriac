# ZeroG


        __________                    ________ 
        \____    /___________  ____  /  _____/ 
          /     // __ \_  __ \/  _ \/   \  ___ 
         /     /\  ___/|  | \(  <_> )    \_\  \
        /_______ \___  >__|   \____/ \______  /
                \/   \/                     \/ 


    Compact replacement for Vala runtime GLib


## Vala Subset
Adriac is a compiler preprocessor for valac, which processes a subset of Vala based on Compact classes. This limits oop functionality, and Genie is not supported. It requires a different coding style, and to set it appart, I'm altering the syle guide, [Based on msn](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions)

* Do use casing instead of underscores.
* Do use Pascal casing for all public member, type, and namespace names.
* Do use camel casing for parameter, field and variable names.
* Do use UPPER_CASE for constants.

Adriac can be used with GLib or with ZeroG.

Parts of zerog are based on the original GLib. There is no GObject. 

Implemented:

* GList & GSList
* GHashTable
* GString
* GArray
* GNode
* GQue


## Demos

### [<del>ShmupWarz II</del> Better Than Shmup](https://darkoverlordofdata.com/zerog-shmupwarz/)
[The old standby](https://github.com/darkoverlordofdata/zerog-shmupwarz)

### [Match3](https://darkoverlordofdata.com/zerog-match3/)
[wip](https://github.com/darkoverlordofdata/zerog-match3)

### [Platformer](https://darkoverlordofdata.com/zerog-platformer/)
[wip](https://github.com/darkoverlordofdata/zerog-platformer)




## License
Various licences apply. 

The ZeroG library and Adriac: GPL2

Application libraries:
* entitas - MIT
* sdx - Apache2
* mt19937 - see code 