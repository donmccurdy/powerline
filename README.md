# [Powerline for Twitter](http://www.donmccurdy.com/powerline)

Create and update Twitter lists through a clean, fast, and simple interface.

***

## Quick Start

### Installation

First-time setup:

```sh
$ npm -g install grunt-cli karma bower
$ git clone git://github.com/donmccurdy/powerline my-project-name
$ cd my-project-name
$ npm install
$ bower install
```

In the future, should you want to add a new Bower package to your app, run the
`install` command:

```sh
$ bower install packagename --save-dev
```

### Development

`grunt watch` will execute a full build up-front and then run incremental
`delta:*` tasks as needed to ensure the fastest possible build. So when
you're working on your project, start with:

```sh
$ grunt watch
```

And everything will be done automatically! You can open `build/index.html`
in your browser, or use a static file server like
[http-server](https://www.npmjs.org/package/http-server). Example:

```sh
# Install and run a simple server.
$ npm install -g http-server
$ http-server ./build
```

Then just open [http://localhost:8080/](http://localhost:8080/) in a browser.
Changes to the code will automatically trigger an update to the build, just
refresh the page (or use LiveReload).

### Production

To initiate a full compile, you simply run the default task:

```sh
$ grunt
```

This will perform a build and then a compile. The compiled site - ready for
uploading to the server! - is located in `bin/`. To test that your full site works as
expected, open the `bin/index.html` file in your browser. Voila!

### To Do

See the [issues list](http://github.com/donmccurdy/powerline/issues). And
feel free to submit your own!

### Credits

Written by [Don McCurdy](https://twitter.com/don_mccurdy).

Based on [ngBoilerplate](https://github.com/ngbp/ngbp), an opinionated kickstarter
for [AngularJS](http://angularjs.org) projects.
