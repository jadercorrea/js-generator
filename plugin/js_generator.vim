function! Strip(input_string)
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Generates the code for a given class
function! ClassFileString(...)
  let l:class_namespace = a:1
  let l:code = ""
  let l:camelCasedClassNames = []

  for i in l:class_namespace
    let l:tmp = substitute(Strip(i), '_\(.\)', '\u\1', 'g')
    call add(l:camelCasedClassNames, l:tmp)
    let l:classChain = join(l:camelCasedClassNames, ".")
  endfor

  let l:class = camelCasedClassNames[-1]

  let l:code = l:code . "class " . l:class . " {\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "  someMethod(opts = []) {\n"
  let l:code = l:code . "    if (opts.length === 0) {\n"
  let l:code = l:code . "      return {\n"
  let l:code = l:code . "        status: 'ok'\n"
  let l:code = l:code . "      };\n"
  let l:code = l:code . "    } else {\n"
  let l:code = l:code . "      return {\n"
  let l:code = l:code . "        status: 'ok',\n"
  let l:code = l:code . "        data: opts\n"
  let l:code = l:code . "      };\n"
  let l:code = l:code . "    }\n"
  let l:code = l:code . "  }\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "  _privateMethod() {\n"
  let l:code = l:code . "    return {\n"
  let l:code = l:code . "      status: 'ok'\n"
  let l:code = l:code . "    };\n"
  let l:code = l:code . "  }\n"
  let l:code = l:code . "}\n"

  return l:code
endfunction

" Generates the test for a given class
function! TestFileString(...)
  let l:class_names = a:1
  let l:code = ""
  let l:camelCasedClassNames = []

  for i in l:class_names
    let l:tmp = substitute(Strip(i), '_\(.\)', '\u\1', 'g')
    call add(l:camelCasedClassNames, l:tmp)
    let l:classChain = join(l:camelCasedClassNames, ".")
  endfor

  let l:class = l:camelCasedClassNames[-1]
  let l:instance = l:class_names[-1]
  let l:code = "const " . l:class . " = require('./src/" . join(l:class_namespace, "/") . "');\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "const " . l:instance . " =  new " .  class . "();"
  let l:code = l:code . "\n"
  let l:code = l:code . "describe('" . l:class . "', () => {\n"
  let l:code = l:code . "  test('someMethod/0', () => {\n"
  let l:code = l:code . "    expect(" . instance . ".someMethod()).toEqual({ status: 'ok' });\n"
  let l:code = l:code . "  });\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "  test('someMethod/1', () => {\n"
  let l:code = l:code . "    expect(" . instance . ".someMethod([1])).toEqual({ status: 'ok', data: [1] });\n"
  let l:code = l:code . "  });\n"
  let l:code = l:code . "});\n"

  return l:code
endfunction

function! JavaScriptGeneratorCreateClassFile()
  let l:class_name = input('Type the path (e.g store/cart/item): ')
  let l:current_dir = getcwd()
  let current_index = 0

  let l:class_names = split(l:class_name, "/")

  " CREATES THE PRODUCTION CODE

  " We're creating these classes inside src/
  exec ":cd ./src"

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  for i in l:class_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:class_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . ".js"
      " Opens it
      execute ":silent e " . l:filename . ".js"
      " Populates it with the boilerplate code
      let l:class_code = ClassFileString(l:class_names)
      execute ":silent normal cc" . l:class_code . "\<Esc>"
      " Saves the current file
      execute ":w"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir

  " CREATES THE TEST CODE

  " We're only creating these classes inside test/
  exec ":cd ./test"

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  let current_index = 0
  for i in l:class_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:class_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . "_test.js"
      " Opens it in a horizontal split
      execute ":vsplit"
      execute ":wincmd l"
      execute ":e " . l:filename . "_test.js"

      " Populates it with the boilerplate code
      let l:class_code = TestFileString(l:class_names)
      execute ":silent normal cc" . l:class_code . "\<Esc>"
      " Saves the current file
      execute ":w"
      execute ":wincmd h"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir
  execute ":redraw!"
endfunction

command! JS call JavaScriptGeneratorCreateClassFile()
