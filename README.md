
# Project of Language and compilers

This is the repository in which all the code and documentation for the project is stored


## Documentation

[Documentation](https://linktodocumentation)

### Description of the language

The developed language allows the programmer to evaluate both boolean and algebric expressions. The language is based on three data types, namely boolean, integer and double, that could be associated either to constant values or to variables. To write a program, two control flow structures could be used, namely the if-then-else and the while loop. Associated to this two structures there are either single-line or multi-line blocks of code. Recalling the C language, single-line blocks could be associate to a flow structure as they are and multi-line blocks must be enclosed in curly brackets. The language allows multiple scope, so visibility of the variables depends on their declaration position. Each block of code associated to a control flow statement is considered as a sub-scope of the main one, and it is indipendent from the other. Consequently, variables decleared in one sub-scope are not accessible from the other sub-scopes, unless they are sub-scopes of the initial subscope. The language offers the possibility of variable redeclaration, but this could happen only if the new variable instance is redecleared in a sub-scope where the previous declaration happened.

Starting from the language description, follows its Formal Grammar.
## Authors

- [@katherinepeterson](https://www.github.com/octokatherine)

  
## Acknowledgements

 - [Awesome Readme Templates](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
 - [Awesome README](https://github.com/matiassingers/awesome-readme)
 - [How to write a Good readme](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)

  
## Badges

Add badges from somewhere like: [shields.io](https://shields.io/)

[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/tterb/atomic-design-ui/blob/master/LICENSEs)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

  
## Features

- Light/dark mode toggle
- Live previews
- Fullscreen mode
- Cross platform

  
## License

[MIT](https://choosealicense.com/licenses/mit/)

  
## Usage/Examples

```javascript
import Component from 'my-project'

function App() {
  return <Component />
}
```

  