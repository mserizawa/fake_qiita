# FakeQiita

* Github like qiita my page.
* This is just a joke app.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Capture

![aa](https://raw.githubusercontent.com/wiki/mserizawa/fake_qiita/images/capture.png)

## How to start

### Your local

First of all, install softwares below.

* elixir
* phoenix
* npm

Next, Setup your Qiita Application.
Please see [this page](http://help.qiita.com/ja/articles/qiita-team-application).

And then, set environments as below.

```sh
CLIENT_ID={ your client id of qiita app }
CLIENT_SECRET={ your client secret of qiita app }
ACCESS_TOKEN={ your access_token }
```

At the end, execute these commands.

```sh
$ git clone https://github.com/mserizawa/fake_qiita.git
$ cd fake_qiita/
$ npm install
$ mix deps.get
$ elixir --detached -S mix phoenix.server
```

### Heroku

Use Deploy to Heroku button and enjoy.

## Recommended browser

* Chrome: latest
* Firefox: latest
* Safari: latest

## TODO

- [x] Discard 'Singin with Qiita'
- [x] Separate layout and page
- [x] Add Ajax Loading
- [x] Handle Exceptions
- [x] Improve caching TTL
- [x] Add other user attributes
- [x] Improve entiries.json response speed (do parallelly)
- [x] Add page to route "/"
- [x] Deploy to somewhere
- [x] Add capture to README
- [ ] Substitute vender.js for JS CDN
- [ ] Remove needless files
