# JS Gerenator
Vim shortcut for easy adding new JS code to your JS application. It creates a lib and a test file for you to start coding.

#### Self-generate modules and unit tests

Hit `:JS` and vim will prompt you to include the path of your new module:

```Type the path (e.g shopping/cart):```

if you type `shopping/cart`, it will generate two files:

* `src/shopping/cart.js`

```javascript
class Cart {
  someMethod(opts = []) {
    if (opts.length === 0) {
      return { status: 'ok' };
    } else {
      return { status: 'ok', data: opts };
    }
  }

  _privateMethod() {
    return { status: 'ok' };
  }
}

module.exports = Cart;
```

* `test/shopping/cart.test.js`

```javascript
const Cart = require('./src/shopping/cart');
const cart = new Cart();

describe('Cart', () => {
  test('someMethod/0', () => {
    expect(cart.someMethod()).toEqual({ status: 'ok' });
  });

  test('someMethod/1', () => {
    expect(cart.someMethod([1])).toEqual({ status: 'ok', data: [1] });
  });
});

```

You may wanna use [vim.test](https://github.com/vim-test/vim-test)
to run your test with a key mapping. If offers a large amount supported languages. For JS usage it is also necessary to specify a runner. 

```
let g:test#javascript#runner = 'jest'
```

#### Contributing
Please consider contributing back.

